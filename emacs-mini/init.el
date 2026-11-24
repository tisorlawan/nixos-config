;;; init.el --- Minimal config for learning Emacs -*- lexical-binding: t -*-

;; Install straight.el on first start, then load it.
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent
         'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'ef-themes)
(load-theme 'ef-spring t)

(defun mini/open-init-file ()
  "Open this config's init.el."
  (interactive)
  (find-file user-init-file))

(global-set-key (kbd "C-x C-, n c") #'mini/open-init-file)
