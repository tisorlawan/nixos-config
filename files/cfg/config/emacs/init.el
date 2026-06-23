;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

(defun config ()
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))

(require 'project)
(add-to-list 'project-vc-extra-root-markers "init.el")

;; @Bootstrap
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; @Appearance
;;; @fonts
(defvar t/font-family "Berkeley Mono")
(defvar t/font-size 130)
(setq-default line-spacing 4)

(defun t/apply-font ()
  (let ((font-spec (font-spec :family t/font-family)))
    (if (find-font font-spec)
        (progn
          (set-face-attribute 'default nil
                              :family t/font-family
                              :height t/font-size)
          (add-to-list 'default-frame-alist
                       `(font . ,(format "%s-%d"
                                         t/font-family
                                         (/ t/font-size 10))))))))


(t/apply-font)

;;; @window
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode 0)
(save-place-mode 1)
(setq inhibit-startup-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message t
      initial-scratch-message nil)
(fringe-mode 3)
(fido-vertical-mode 1)

;;; @theme
(load-theme 'modus-vivendi-tinted)
