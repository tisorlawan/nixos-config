;;; early-init.el --- Early startup settings -*- lexical-binding: t -*-

;; Avoid package.el activation because straight.el owns package loading.
(setq package-enable-at-startup nil
      ;; Defer GC while Emacs loads the init file and packages.
      gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; File-name handlers perform expensive regular-expression checks for every
;; file operation.  They are not needed while loading local configuration.
(defvar my/startup-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(defun my/restore-startup-performance-settings ()
  "Restore normal GC and file-name-handler behavior after startup."
  (setq gc-cons-threshold (* 8 1024 1024)
        gc-cons-percentage 0.1
        file-name-handler-alist
        (append file-name-handler-alist my/startup-file-name-handler-alist)))

(add-hook 'emacs-startup-hook #'my/restore-startup-performance-settings)
