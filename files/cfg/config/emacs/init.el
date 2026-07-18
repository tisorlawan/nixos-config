;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

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
(defvar t/font-size 140)
(setq-default line-spacing 5)

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
(load-theme 'modus-vivendi-tinted)
(setq-default scroll-margin 5)
(setq-default line-spacing 4)
(add-hook 'before-save-hook #'delete-trailing-whitespace)
(setq whitespace-style '(face tabs trailing tab-mark)
      whitespace-display-mappings '((tab-mark ?\t [?› ?\t] [?\\ ?\t])))
(global-whitespace-mode 1)

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
(fringe-mode 0)
(fido-mode 0)
(electric-pair-mode 1)


;;; @git
(use-package magit
  :straight t
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1))

;;; @evil
;; (use-package evil
;;   :straight t
;;   :config
;;   (evil-mode 1)
;;   (define-key evil-normal-state-map (kbd "SPC w") #'save-buffer)
;; )

;; (use-package evil-commentary
;;   :straight t
;;   :config
;;   (evil-commentary-mode))


;;; @minibuffer
(use-package vertico
  :straight t
  :custom
  (vertico-scroll-margin 0) ;; Different scroll margin
  (vertico-count 6) ;; Show more candidates
  (vertico-resize nil) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

;;; @search
;; (use-package consult :straight t)
;; (use-package writeroom-mode :straight t)
;; (setq-default indent-tabs-mode nil
;;               tab-width 4)
