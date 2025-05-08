;;; lmno-export.el --- Export LMNO blog posts from Org to Markdown -*- coding: utf-8 -*-
;;
;; Author: Mike Hall <mike@puddingtime.org>
;; Version: 0.1
;; Keywords: org, markdown, blog
;; Package-Requires: ((emacs "25.1") (org "9.0"))
;;
;;; Commentary:
;; A simple package to export an Org file to Markdown,
;; stripping unwanted artifacts (anchors, spans, metadata),
;; and opening the resulting Markdown file in full frame.
;;
;;; Code:

(defgroup lmno-org nil
  "LMNO blog exporter from Org to Markdown."
  :group 'org
  :prefix "lmno-org-")

(defcustom lmno-org-input-file "~/notes/lmno.org"
  "Path to the Org file to export for the LMNO blog."
  :type 'file
  :group 'lmno-org)

(defcustom lmno-org-output-file "~/notes/lmno.md"
  "Path to the output Markdown file for the LMNO blog."
  :type 'file
  :group 'lmno-org)

(defun lmno-org--strip-span-and-anchors (output backend info)
  "Remove HTML anchors and span wrappers from OUTPUT for Markdown export."
  (if (org-export-derived-backend-p backend 'md)
      (let ((s output))
        (setq s (replace-regexp-in-string "<a id=\"[^\"]+\"></a>" "" s))
        (setq s (replace-regexp-in-string "</?span[^>]*>" "" s))
        s)
    output))

;;;###autoload
(defun lmno-org-export-blog (&optional input-file output-file)
  "Export INPUT-FILE (Org) to OUTPUT-FILE (Markdown) for the LMNO blog.
Uses `lmno-org-input-file' and `lmno-org-output-file' if arguments are nil.
Strips unwanted metadata, anchors, and spans, then opens the result in full frame."
  (interactive)
  (let* ((in-file  (or input-file lmno-org-input-file))
         (out-file (or output-file lmno-org-output-file))
         ;; disable unwanted exporter features
         (org-export-with-toc            nil)
         (org-export-with-section-numbers nil)
         (org-export-with-author         nil)
         (org-export-with-creator        nil)
         (org-export-with-date           nil)
         (org-export-with-priorities     nil)
         (org-export-with-timestamps     nil)
         (org-export-with-smart-quotes   nil)
         (org-export-with-broken-links   'mark)
         ;; hook our strip filter
         (org-export-filter-final-output-functions
          (list #'lmno-org--strip-span-and-anchors)))
    ;; read Org file and export to Markdown string
    (with-temp-buffer
      (insert-file-contents in-file)
      (org-mode)
      (let ((md (org-export-as 'md nil nil t nil)))
        ;; write the output to file
        (with-temp-file out-file
          (insert md))))
    ;; visit the generated Markdown full-frame
    (find-file out-file)
    (delete-other-windows)
    (message "Clean LMNO export complete → %s" out-file)))

(provide 'lmno-export)
;;; lmno-export.el ends here
