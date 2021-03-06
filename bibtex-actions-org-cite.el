;;; bibtex-actions-org-cite.el --- Org-cite support for bibtex-actions -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 Bruce D'Arcus
;;
;; Author: Bruce D'Arcus <https://github.com/bdarcus>
;; Maintainer: Bruce D'Arcus <https://github.com/bdarcus>
;; Created: July 11, 2021
;; License: GPL-3.0-or-later
;; Version: 0.1
;; Homepage: https://github.com/bdarcus/bibtex-actions
;; Package-Requires: ((emacs "26.3")(org "9.5"))
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;;  This is a small package that intergrates bibtex-actions and org-cite.  It
;;  provides a simple org-cite processor with "follow" and "insert" capabilties.
;;
;;  Simply load this file and it will configure them for 'org-cite.'
;;
;;; Code:

(require 'bibtex-actions)
(require 'org)
(require 'oc)
(require 'oc-basic)
(require 'embark)

(declare-function bibtex-actions-at-point "bibtex-actions")
(declare-function org-open-at-point "org")

;TODO
;(defvar bibtex-actions-org-cite-open-default

;; Org-cite processor

(defun bibtex-actions-org-cite-insert (&optional multiple)
  "Return a list of keys when MULTIPLE, or else a key string."
  (let ((references (bibtex-actions-read)))
    (if multiple
        references
      (car references))))

(defun bibtex-actions-org-cite-follow (_datum _arg)
  "Follow processor for org-cite."
  (call-interactively bibtex-actions-at-point-function))

(org-cite-register-processor 'bibtex-actions-org-cite
  :insert (org-cite-make-insert-processor
           #'bibtex-actions-org-cite-insert
           #'org-cite-basic--complete-style)
  :follow #'bibtex-actions-org-cite-follow)

;;; Embark target finder

(defun bibtex-actions-org-cite-citation-finder ()
  "Return org-cite citation keys at point as a list for `embark'."
  (when-let ((keys (bibtex-actions-get-key-org-cite)))
    (cons 'oc-citation (bibtex-actions--stringify-keys keys))))

;;; Keymap

(defvar bibtex-actions-org-cite-map
  (let ((map (make-sparse-keymap)))
    (define-key map "c" '("cite | insert/edit" . org-cite-insert))
    (define-key map "o" '("cite | open-at-point" . bibtex-actions-open))
    (define-key map "e" '("cite | open/edit entry" . bibtex-actions-open-entry))
    (define-key map "n" '("cite | open notes" . bibtex-actions-open-notes))
    (define-key map (kbd "RET") '("cite | default action" . bibtex-actions-run-default-action))
    map)
  "Keymap for 'bibtex-actions-org-cite' `embark' at-point functionality.")

;; Bibtex-actions-org-cite configuration

(setq org-cite-follow-processor 'bibtex-actions-org-cite)
(setq org-cite-insert-processor 'bibtex-actions-org-cite)
(setq bibtex-actions-at-point-function 'embark-dwim)

;; Embark configuration for org-cite

(add-to-list 'embark-target-finders 'bibtex-actions-org-cite-citation-finder)
(add-to-list 'embark-keymap-alist '(bibtex . bibtex-actions-map))
(add-to-list 'embark-keymap-alist '(oc-citation . bibtex-actions-org-cite-map))

(provide 'bibtex-actions-org-cite)
;;; bibtex-actions-org-cite.el ends here
