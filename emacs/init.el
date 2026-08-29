;; -*- lexical-binding: t -*-
;; @shell

(defvar my/shell "/usr/bin/fish"
  "Shell used by ghostel, shell, term, and compilation.")

(setenv "SHELL" my/shell)
(setq shell-file-name my/shell
      explicit-shell-file-name my/shell)

;; @bootstrap
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file :no-error-if-file-is-missing)
(setq custom-safe-themes t
      use-short-answers t)

;; straight checks each package's git state on every start; this is a large
;; share of bootstrap cost. This config is git-managed and stable, so skip it.
(setq straight-check-for-modifications nil)
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
         'silent
         'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(add-to-list 'load-path
             (expand-file-name "lisp"
                               (file-name-directory (or load-file-name
                                                        buffer-file-name))))

(defun my/prepend-executable-directory (directory)
  "Make executables in DIRECTORY available to Emacs and child processes."
  (let ((directory (directory-file-name (expand-file-name directory))))
    (when (file-directory-p directory)
      (add-to-list 'exec-path directory)
      (setenv "PATH"
              (mapconcat #'identity
                         (delete-dups
                          (cons directory
                                (parse-colon-path (or (getenv "PATH") ""))))
                         path-separator)))))

;; GUI Emacs does not necessarily inherit the shell's PATH.
(my/prepend-executable-directory "~/.bun/bin")
(my/prepend-executable-directory "~/.cache/npm/global/bin")
(my/prepend-executable-directory "~/.opencode/bin")
(my/prepend-executable-directory "~/.cargo/bin")
(my/prepend-executable-directory "~/.nix-profile/bin")

;; Locally compiled tree-sitter grammars (js/ts/tsx) live in tree-sitter/
;; inside this config; see tree-sitter/README note in the repo.
(add-to-list 'treesit-extra-load-path (locate-user-emacs-file "tree-sitter"))

(defun my/reset-font ()
  "Restore the configured fonts, line spacing, and text scale."
  (interactive)
  (setq-default line-spacing 0.05)
  (set-face-attribute 'default nil        :family "Berkeley Mono"       :height 140)
  (set-face-attribute 'fixed-pitch nil    :family "Aporetic Serif Mono" :height 1.0)
  (set-face-attribute 'variable-pitch nil :family "Aporetic Sans"       :height 1.0)
  (text-scale-set 0.0))

(defun my/toggle-frame-transparency ()
  "Toggle the selected graphical frame background between opaque and 90% opacity."
  (interactive)
  (if (not (display-graphic-p))
      (user-error "Frame transparency requires a graphical display")
    (let ((transparent-p (equal (frame-parameter nil 'alpha-background) 90)))
      (set-frame-parameter nil 'alpha-background (if transparent-p 100 90))
      (message "Frame transparency %s"
               (if transparent-p "disabled" "enabled")))))

(defun my/enable-frame-transparency (&optional frame)
  "Set FRAME's background to 90% opacity."
  (set-frame-parameter frame 'alpha-background 90))

(when (display-graphic-p)
  (my/enable-frame-transparency))
(add-hook 'after-make-frame-functions #'my/enable-frame-transparency)

(defun my/current-theme ()
  "Display the currently enabled theme."
  (interactive)
  (message "%s" (car custom-enabled-themes)))

(defun my/cycle-line-numbers ()
  "Cycle line numbers through hidden, relative, and absolute."
  (interactive)
  (cond
   ((not display-line-numbers)
    (display-line-numbers-mode 1)
    (setq-local display-line-numbers 'relative)
    (message "Relative line numbers enabled"))
   ((eq display-line-numbers 'relative)
    (setq-local display-line-numbers t)
    (message "Absolute line numbers enabled"))
   (t
    (display-line-numbers-mode -1)
    (message "Line numbers disabled"))))

(defun my/keyboard-quit-dwim ()
  "Quit the active region, completion window, minibuffer, or command."
  (interactive)
  (cond ((region-active-p)
         (keyboard-quit))
        ((derived-mode-p 'completion-list-mode)
         (delete-completion-window))
        ((> (minibuffer-depth) 0)
         (abort-recursive-edit))
        (t
         (keyboard-quit))))

(defun my/change-inside-pair (delete-only)
  "Remove contents of the enclosing pair."
  (interactive "P")
  (let* ((open (save-excursion
		 (backward-up-list)
		 (point)))
	 (close (scan-sexps open 1))
	 (start (1+ open))
	 (end (1- close)))
    (if delete-only
	(delete-region start end)
      (kill-region start end))))


(defun my/edit-file (path)
  (lambda ()
    (interactive)
    (find-file (expand-file-name path))))

(defun my/copy-file-path (absolute)
  "Copy the current file's path to the kill ring.
Relative to the project root when ABSOLUTE is nil, absolute otherwise."
  (interactive "P")
  (unless buffer-file-name
    (user-error "Buffer is not visiting a file"))
  (let ((path (if absolute
                  buffer-file-name
                (let ((root (and (fboundp 'project-current)
                                 (project-current)
                                 (project-root (project-current)))))
                  (if (and root (file-in-directory-p buffer-file-name root))
                      (file-relative-name buffer-file-name root)
                    (file-relative-name buffer-file-name
                                        default-directory))))))
    (kill-new path)
    (message "Copied %s" path)))

(defun my/copy-file-path-absolute ()
  "Copy the current file's absolute path to the kill ring."
  (interactive)
  (my/copy-file-path t))

(defvar my/notes-directory  (expand-file-name "~/notes/"))
(defvar my/credentials-file (expand-file-name "~/Documents/credentials/acc.txt"))
(defvar my/secrets-file     (expand-file-name "~/.rice/secrets.org.gpg"))
(defvar my/backup-directory (locate-user-emacs-file "backups/"))

(use-package emacs
  :config

  ;; @modes
  (column-number-mode 1)
  (prefer-coding-system 'utf-8)
  (global-hl-line-mode -1)
  (blink-cursor-mode 0)
  (which-key-mode 1)
  (save-place-mode 1)
  (savehist-mode 1)
  (make-directory my/backup-directory t)
  (setq backup-directory-alist `(("." . ,my/backup-directory)))

  (defun my/disable-electric-pair-in-minibuffer ()
    (electric-pair-local-mode -1))

  (electric-pair-mode 1)
  (add-hook 'minibuffer-setup-hook #'my/disable-electric-pair-in-minibuffer)

  ;; Corfu owns automatic completions; completion-preview duplicates its CAPF
  ;; query immediately at the third symbol character.
  (global-completion-preview-mode -1)

  (when (window-system)
    (tool-bar-mode -1)
    (menu-bar-mode -1)
    (scroll-bar-mode -1))

  ;; @appearance
  (my/reset-font)
  ;; Let HarfBuzz shape common programming operators as font ligatures.
  (dolist (rule '((?= . "\\(?:==\\|=>\\)")
                  (?! . "\\(?:!=\\)")
                  (?< . "\\(?:<=\\)")
                  (?> . "\\(?:>=\\)")
                  (?- . "\\(?:--\\|->\\)")
                  (?: . "\\(?:::\\|:=\\)")))
    (set-char-table-range composition-function-table (car rule)
                          `([,(cdr rule) 0 font-shape-gstring])))


  ;; @keybind
  (global-set-key (kbd "C-g")      #'my/keyboard-quit-dwim)
  (global-set-key (kbd "M-o")      #'other-window)
  (global-set-key (kbd "C-c k")    #'kill-current-buffer)
  (global-set-key (kbd "M-<up>")   #'previous-error)
  (global-set-key (kbd "M-<down>") #'next-error)
  (global-set-key (kbd "C-c i")    #'my/change-inside-pair)
  (dolist (map (list minibuffer-local-map
                     minibuffer-local-completion-map
                     minibuffer-local-must-match-map
                     minibuffer-local-filename-completion-map))
    (keymap-set map "C-w" #'backward-kill-word))

  (global-set-key (kbd "C-x j") (lambda ()
				  (interactive)
				  (switch-to-buffer (other-buffer))))

  (global-set-key (kbd "C-S-<backspace>") #'my/reset-font)

  (global-set-key (kbd "C-x C-, n a")
		  (my/edit-file my/credentials-file))
  (global-set-key (kbd "C-x C-, n n")
		  (my/edit-file (expand-file-name "TODO.org" my/notes-directory)))
  (global-set-key (kbd "C-x C-, n l")
		  (my/edit-file (expand-file-name "til.org" my/notes-directory)))
  (global-set-key (kbd "C-x C-, n C")
		  (my/edit-file (expand-file-name "COMMANDS.org" my/notes-directory)))
  (global-set-key (kbd "C-x C-, n c")
		  (my/edit-file (locate-user-emacs-file "init.el")))
  (global-set-key (kbd "C-x C-, n s")
		  (my/edit-file my/secrets-file))

  (global-set-key (kbd "C-x C-, f r") #'consult-recent-file)
  (global-set-key (kbd "C-x C-, d t") #'my/current-theme)

  (global-set-key (kbd "C-x C-, t i") #'eglot-momentary-inlay-hints)
  (global-set-key (kbd "C-x C-, t n") #'my/cycle-line-numbers)
  (global-set-key (kbd "C-x C-, t p") #'electric-pair-mode)
  (global-set-key (kbd "C-x C-, t D") #'my/toggle-flymake-eol-diagnostics)
  (global-set-key (kbd "C-x C-, y p") #'my/copy-file-path)
  (global-set-key (kbd "C-x C-, y P") #'my/copy-file-path-absolute)
  (global-set-key (kbd "C-x C-, t r") #'my/toggle-frame-transparency))


(use-package which-key
  :straight nil
  :config
  (which-key-add-key-based-replacements
    "C-x C-," "Tiso"
    "C-x C-, n" "Notes"
    "C-x C-, n n" "TODO"
    "C-x C-, n l" "til"
    "C-x C-, n a" "Account"
    "C-x C-, n c" "init.el"
    "C-x C-, n C" "Commands"
    "C-x C-, n s" "secret"
    "C-x C-, d t" "Current Theme"

    "C-x C-, t d" "Toggle Diagnostics"
    "C-x C-, t D" "Toggle EOL Diagnostics"
    "C-x C-, t n" "Line Numbers"
    "C-x C-, t p" "Auto Pair"
    "C-x C-, t r" "Transparency"

    "C-x C-, f" "Find"
    "C-x C-, y" "Copy Path"
    "C-x C-, y p" "Project-Relative Path"
    "C-x C-, y P" "Absolute Path"
    "C-x C-, f r" "Recent Files"

    "C-x C-, c" "Code"
    "C-x C-, e" "File Explorer"

    "C-x j" "Toggle Buffer"))


(use-package ef-themes
  :config
  (load-theme 'ef-maris-dark))


(use-package isearch
  :straight nil
  :config
  (setq isearch-lazy-count t
        lazy-count-prefix-format "[%s/%s] "
        lazy-count-suffix-format nil))


(use-package vertico    :config (vertico-mode 1))
(use-package marginalia :config (marginalia-mode 1))
(use-package orderless  :config (setq completion-styles '(orderless basic)))
(use-package corfu
  :init
  (defun my/toggle-corfu-auto ()
    "Toggle automatic Corfu completion globally."
    (interactive)
    (setq corfu-auto (not corfu-auto))
    ;; Restart Corfu so every buffer receives the new auto-completion hooks.
    (global-corfu-mode -1)
    (global-corfu-mode 1)
    (message "Corfu auto completion %s"
             (if corfu-auto "enabled" "disabled")))
  (global-corfu-mode 1)
  :bind
  (("M-SPC" . completion-at-point)
   ("C-x C-, t a" . my/toggle-corfu-auto))
  :custom
  (corfu-auto nil)
  (corfu-auto-delay 0.2)
  (corfu-quit-no-match 'separator)
  :config
  (defun my/corfu-quit-and-newline ()
    "Dismiss Corfu and insert a newline without completing."
    (interactive)
    (corfu-quit)
    (newline))
  (keymap-set corfu-map "RET" #'my/corfu-quit-and-newline))


(use-package recentf
  :straight nil
  :init
  (recentf-mode 1))


(use-package doom-modeline
  :init
  (doom-modeline-mode 1))


(use-package consult
  :bind
  (("M-s l" . consult-line)
   ("M-s g" . consult-ripgrep))
  :init
  (setq consult-async-refresh-delay 0.05)
  :config
  (setq consult-ripgrep-args
	(string-replace "--smart-case" "--ignore-case" consult-ripgrep-args)))

(use-package tiso-fff
  :straight nil
  :after consult)


(use-package embark-consult
  :after (embark consult))


(use-package embark
  :bind
  (("C-," . embark-act)))


(use-package avy
  :bind
  (("M-j" . avy-goto-char-timer))
  :custom
  (avy-timeout-seconds 0.35)
  :init
  (defun my--leap-avy-handler (char)
    (if (memq char avy-escape-chars)
        (throw 'done 'abort)
      (setq unread-command-events
            (nconc (listify-key-sequence (vector char))
                   unread-command-events))
      (throw 'done 'exit)))

  (defun my--leap-jump (char1 char2 beg end)
    (require 'avy)
    (let* ((regexp (regexp-quote (string char1 char2)))
           (candidates (let ((avy-all-windows nil))
                         (avy--regex-candidates regexp beg end))))
      (if (null candidates)
          (message "Leap: no match for %c%c" char1 char2)
        (let* ((origin (point))
               (sorted
                (sort candidates
                      (lambda (left right)
                        (< (abs (- (caar left) origin))
                           (abs (- (caar right) origin))))))
               (nearest (car sorted))
               (remaining (cdr sorted)))
          (when (fboundp 'evil-set-jump)
            (evil-set-jump))
          (avy-push-mark)
          (goto-char (caar nearest))
          (when remaining
            (let ((avy-handler-function #'my--leap-avy-handler)
                  (avy-single-candidate-jump nil))
              (avy-process remaining)))))))

  (defun my/leap-forward (char1 char2)
    "Leap to a CHAR1 CHAR2 match below point."
    (interactive (list (read-char "Leap: " t) (read-char nil t)))
    (my--leap-jump char1 char2
                   (min (1+ (point)) (point-max))
                   (window-end (selected-window) t)))

  (defun my/leap-backward (char1 char2)
    "Leap to a CHAR1 CHAR2 match above point."
    (interactive (list (read-char "Leap: " t) (read-char nil t)))
    (my--leap-jump char1 char2
                   (window-start (selected-window))
                   (point))))


(use-package project
  :straight nil
  :init
  (defun my/project-remember ()
    "Prompt for a project and add it to the known-project list."
    (interactive)
    (let ((project-list-exclude nil))
      (call-interactively #'project-remember-project)))
  :bind
  (("C-x p a" . my/project-remember))
  :config
  (setq project-vc-extra-root-markers '("pyproject.toml" "Cargo.toml")
        project-list-exclude (list (lambda (_project) t))))


(use-package magit
  :defer t
  :custom
  (git-commit-summary-max-length 50)
  ;; Workaround for magit bug: async git commands crash with
  ;; "Wrong type argument: stringp, nil" because
  ;; (locate-library "magit.el") returns nil when magit is loaded
  ;; from compiled .elc files (straight build dir).
  (magit-run-hooks-from-githooks nil)
  :hook
  (git-commit-setup . (lambda ()
                        (setq-local fill-column 72)
                        (display-fill-column-indicator-mode 1)))
  :config
  (setq magit-display-buffer-function 'magit-display-buffer-fullcolumn-most-v1)
  (setq magit-process-popup-time 2))


(use-package treemacs
  :bind
  (("C-x C-, e" . treemacs))
  :custom
  (treemacs-width 32)
  (treemacs-position 'left)
  (treemacs-is-never-other-window nil)
  (treemacs-follow-after-init t)
  (treemacs-silent-refresh t)
  :config
  (treemacs-follow-mode 1)
  (treemacs-filewatch-mode 1)
  (treemacs-hide-gitignored-files-mode 1)
  ;; The gitignore prefetch runs before any project is loaded from the
  ;; persist file, so the first render still shows ignored entries. Refresh
  ;; once the deferred git status has filled the ignore cache.
  (defun my/treemacs-refresh-after-cache-fill ()
    "Refresh this Treemacs buffer once its git ignore cache is filled."
    (let ((buffer (current-buffer)))
      (run-with-timer 3 nil
                      (lambda ()
                        (when (buffer-live-p buffer)
                          (with-current-buffer buffer
                            (treemacs--do-refresh (current-buffer) 'all)))))))
  (add-hook 'treemacs-mode-hook #'my/treemacs-refresh-after-cache-fill)
  (setq treemacs-show-hidden-files nil))


(use-package nerd-icons)

(use-package treemacs-nerd-icons
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))

(use-package dired-x
  :straight nil
  :after dired
  :hook (dired-mode . dired-omit-mode)
  :config
  (setq dired-omit-files
        (concat dired-omit-files
                "\\|^__pycache__$"
                "\\|^\\.venv$"
                "\\|^node_modules$"
                "\\|^\\.pytest_cache$"
                "\\|\\.pyc\\'")))
 
 
 (use-package treemacs-evil
   :after (treemacs evil))


(use-package treemacs-evil
  :after (treemacs evil)
  :config
  (define-key evil-treemacs-state-map (kbd "SPC e") #'treemacs))

;; @evil

(defun my--evil-pulse-yank (beg end &rest _)
  (pulse-momentary-highlight-region beg end))

(use-package evil
  :init
  (setq evil-want-keybinding nil
        evil-disable-insert-state-bindings t
        evil-split-window-below t
        evil-vsplit-window-right t)
  :config
  (evil-mode 1)
  (advice-add 'evil-yank :after #'my--evil-pulse-yank)
  (require 'tiso-fff)
  (evil-define-key 'insert global-map (kbd "C-w") #'evil-delete-backward-word)
  (evil-define-key 'normal global-map (kbd "Y") (kbd "y$"))
  (evil-define-key 'normal global-map (kbd "C-p") #'tiso/fff-find-file)
  (evil-define-key 'normal global-map (kbd "C-n") #'consult-buffer)
  (evil-define-key 'normal 'global (kbd "s") #'my/leap-forward)
  (evil-define-key 'normal 'global (kbd "S") #'my/leap-backward)
  (evil-define-key 'normal global-map (kbd "SPC w") #'save-buffer)
  (evil-define-key 'normal global-map (kbd "SPC d") #'kill-current-buffer)
  (evil-define-key 'normal global-map (kbd "SPC e") #'treemacs)
  (evil-define-key 'normal global-map (kbd "SPC E")
                   #'treemacs-add-and-display-current-project-exclusively)
  (evil-define-key 'normal prog-mode-map
    (kbd "[ d") #'flymake-goto-prev-error
    (kbd "] d") #'flymake-goto-next-error)
  (evil-define-key '(normal visual) global-map (kbd "SPC l") #'tiso/fff-grep))

(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode 1))

(use-package evil-visualstar
  :after evil
  :config
  (global-evil-visualstar-mode 1))


;; @diagnostics

(define-minor-mode my/global-flymake-mode
  "Globally allow Flymake, including Flymake managed by Eglot."
  :global t
  :init-value t
  (require 'eglot)
  (if my/global-flymake-mode
      (setq eglot-stay-out-of (delq 'flymake eglot-stay-out-of))
    (add-to-list 'eglot-stay-out-of 'flymake))
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (if my/global-flymake-mode
                (eglot-managed-p)
              flymake-mode)
        (flymake-mode (if my/global-flymake-mode 1 -1))
        ;; `flymake-mode -1' leaves Eglot's report function in place, so a
        ;; diagnostics push after save would still draw overlays.
        (unless my/global-flymake-mode
          (setq-local eglot--flymake-report-fn nil))))))



(use-package flymake
  :straight nil
  :bind
  (("C-x C-, t d" . my/global-flymake-mode))
  :init
  (defun my--keep-flymake-globally-disabled ()
    (when (and flymake-mode (not my/global-flymake-mode))
      (flymake-mode -1)))

  (defun my--flymake-delete-overlays ()
    (remove-overlays (point-min) (point-max) 'flymake-overlay t))

  (defun my--flymake-hide-diagnostics-after-change (&rest _)
    (my--flymake-delete-overlays))

  (defun my--flymake-hide-dirty-buffer-diagnostics ()
    (add-hook 'after-change-functions
              #'my--flymake-hide-diagnostics-after-change nil t))

  (defun my--flymake-hide-dirty-diagnostics-after-report (&rest _)
    (when (buffer-modified-p)
      (my--flymake-delete-overlays)))

  (defun my--flymake-straight-underlines (&rest _)
    "Display Flymake diagnostics with low, straight underlines."
    (dolist (face '(flymake-error flymake-warning flymake-note))
      (set-face-attribute face nil :underline '(:style line :position t))))
  :config
  (setq flymake-show-diagnostics-at-end-of-line 'short)

  (defun my/toggle-flymake-eol-diagnostics ()
    "Toggle showing Flymake diagnostics at end of line."
    (interactive)
    (if flymake-show-diagnostics-at-end-of-line
        (progn
          (setq flymake-show-diagnostics-at-end-of-line nil)
          (dolist (o (overlays-in (point-min) (point-max)))
            (when (overlay-get o 'flymake--eol-overlay)
              (delete-overlay o)))
          (message "Flymake end-of-line diagnostics hidden"))
      (setq flymake-show-diagnostics-at-end-of-line 'short)
      (when flymake-mode (flymake-start))
      (message "Flymake end-of-line diagnostics shown")))
  (add-hook 'flymake-mode-hook #'my--keep-flymake-globally-disabled)
  (add-hook 'flymake-mode-hook #'my--flymake-hide-dirty-buffer-diagnostics)
  (advice-add 'flymake--handle-report
              :after #'my--flymake-hide-dirty-diagnostics-after-report)
  (add-hook 'enable-theme-functions #'my--flymake-straight-underlines)
  (my--flymake-straight-underlines))

(defun my--eldoc-diagnostics-only ()
  "Let Eldoc display Flymake diagnostics, not language-server documentation."
  (require 'flymake)
  (setq-local eldoc-documentation-functions '(flymake-eldoc-function)))

(add-hook 'prog-mode-hook #'my--eldoc-diagnostics-only)
(setq eldoc-echo-area-use-multiline-p t)
(use-package markdown-mode
  :demand t
  :mode ("\\.\\(?:md\\|markdown\\|mkd\\|mdown\\|mkdn\\|mdwn\\|mdx\\)\\'" . gfm-view-mode)
  :hook (gfm-view-mode . my/gfm-view-scale-headings)
  :bind (:map gfm-mode-map
              ("C-c RET" . my/toggle-gfm-view))
  :config
  (defun my/gfm-view-scale-headings ()
    "Scale GFM headings according to their level."
    (face-remap-add-relative 'markdown-header-face-1 '(:height 1.5))
    (face-remap-add-relative 'markdown-header-face-2 '(:height 1.4))
    (face-remap-add-relative 'markdown-header-face-3 '(:height 1.3))
    (face-remap-add-relative 'markdown-header-face-4 '(:height 1.2))
    (face-remap-add-relative 'markdown-header-face-5 '(:height 1.1))
    (face-remap-add-relative 'markdown-header-face-6 '(:height 1.0)))

  (defun my/toggle-gfm-view ()
    "Toggle between editable and read-only GFM modes."
    (interactive)
    (if (derived-mode-p 'gfm-view-mode)
        (gfm-mode)
      (gfm-view-mode)))

  (add-to-list 'markdown-code-lang-modes '("tsx" . tsx-ts-mode))
  (add-to-list 'markdown-code-lang-modes '("jsx" . tsx-ts-mode))
  (add-to-list 'markdown-code-lang-modes '("js" . js-ts-mode))
  (add-to-list 'markdown-code-lang-modes '("ts" . typescript-ts-mode)))

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(use-package json-mode
  :mode "\\.jsonc?\\'")

(use-package toml-mode
  :mode "\\.toml\\'")

;; Treat built-in org as available so straight does not clone it for
;; org-appear dependencies.
(add-to-list 'straight-built-in-pseudo-packages 'org)

(use-package org
  :straight nil
  :init
  (defun my/org-heading-scale ()
    "Scale org heading faces by level."
    (dolist (pair '((1 . 1.15) (2 . 1.10) (3 . 1.05) (4 . 1.0) (5 . 0.95) (6 . 0.90)))
      (face-remap-add-relative
       (intern (format "org-level-%d" (car pair)))
       `(:height ,(cdr pair)))))
  :hook
  (org-mode . org-indent-mode)
  (org-mode . org-appear-mode)
  (org-mode . my/org-heading-scale)
  :config
  (setq org-ellipsis " ▾"
        org-hide-emphasis-markers t)
  (setq org-appear-autoemphasis t
        org-appear-autolinks t
        org-appear-autoentities t
        org-appear-autosubmarkers t))

(use-package org-appear
  :after org)


;; Eglot advertises the `snippetSupport' capability to language servers only
;; while Yasnippet is loaded, so it must load eagerly at init, before any
;; server connects.  Yasnippet itself is enabled only in Eglot-managed
;; buffers, where it expands parameter placeholders on accepted completions.
(use-package yasnippet
  :config
  (defun my/corfu-popup-open-p ()
    "Return non-nil while Corfu's completion popup is shown."
    (and (bound-and-true-p corfu-mode) corfu--input))
  ;; While Corfu's popup is open, disable Yasnippet's field keymap so TAB
  ;; completes the selected candidate instead of jumping to the next
  ;; snippet placeholder.
  (add-hook 'yas-keymap-disable-hook #'my/corfu-popup-open-p))
(use-package eglot
  :straight nil
  :bind
  (("C-x C-, c e" . eglot)
   ("C-x C-, c a" . eglot-code-actions)
   ("C-x C-, c r" . my/eglot-rename))
  :init
  (setq eglot-ignored-server-capabilities '(:inlayHintProvider)
        ;; Never stall file opening while a language server boots; the
        ;; connection completes in the background instead.
        eglot-sync-connect nil)
  ;; LSP servers can emit large bursts of output; read process pipes in
  ;; 1MB chunks instead of the 64KB default so chatty servers (rust-analyzer,
  ;; clangd) don't bottleneck on emacs process input.
  (setq read-process-output-max (* 1024 1024))
  :config
  (add-to-list 'eglot-server-programs '(zig-mode . ("zls")))
  ;; clangd omits parameter placeholders by default; snippets require
  ;; --function-arg-placeholders.  Keep the ccls fallback for machines
  ;; without clangd.
  (add-to-list 'eglot-server-programs
               `((c-mode c-ts-mode c++-mode c++-ts-mode objc-mode)
                 . ,(eglot-alternatives
                     '(("clangd" "--function-arg-placeholders") "ccls"))))

  ;; Prefer pyrefly for Python; fall back to basedpyright where pyrefly is
  ;; not installed.
  (add-to-list 'eglot-server-programs
               `((python-mode python-ts-mode)
                 . ,(eglot-alternatives
                     '(("pyrefly" "lsp") ("basedpyright-langserver" "--stdio")))))

  ;; Web: typescript-language-server for TS/TSX/JS (incl. JSX via tsx grammar).
  (add-to-list 'eglot-server-programs
               '((js-ts-mode tsx-ts-mode typescript-ts-mode)
                 . ("typescript-language-server" "--stdio")))
  (setq-default eglot-workspace-configuration
                '(:python.analysis
                  (:autoImportCompletions :json-false)
                  :basedpyright.analysis
                  (:autoImportCompletions :json-false)))

  ;; Request Markdown from language servers and preserve native code faces.

  (setq eglot-documentation-renderer 'gfm-view-mode)
  (defun my/eglot-rename (new-name)
    "Rename the symbol at point, pre-filling its current name."
    (interactive
     (list (read-string "Rename to: "
                        (or (thing-at-point 'symbol t)
                            (user-error "No symbol at point")))))
    (eglot-rename new-name))

  (defun my--eglot-clear-code-action-suggestion (&rest _)
    "Hide code action suggestions for stale buffer contents."
    (when (local-variable-p 'eglot--suggestion-overlay)
      (delete-overlay eglot--suggestion-overlay)))

  (defun my--eglot-query-code-actions-after-save ()
    "Request code actions at point after a successful save."
    (when (eglot-managed-p)
      (eglot-code-action-suggestion #'ignore)))

  (defun my/eglot-hover ()
    "Show language-server documentation for the symbol at point."
    (interactive)
    (when (eglot-current-server)
      (eglot-hover-eldoc-function
       (lambda (documentation &rest _)
         (when documentation
           (let ((buffer (get-buffer-create "*eglot-hover*")))
             (with-current-buffer buffer
               (let ((inhibit-read-only t))
                 (erase-buffer)
                 (insert (string-replace "&nbsp;" " " documentation))
                 (goto-char (point-min)))
               (help-mode)
               (evil-local-mode 1)
               (evil-local-set-key 'normal (kbd "q") #'quit-window)
               (evil-normal-state))
             (display-buffer buffer)))))))

  (defun my/eglot-signature ()
    "Show the language-server signature help for the call at point."
    (interactive)
    (when (eglot-current-server)
      (eglot-signature-eldoc-function
       (lambda (signature &rest _)
         (when signature
           (message "%s" signature))))))

  (defun my--eglot-bind-hover-keys ()
    "Install buffer-local manual hover bindings for Evil."
    (evil-local-set-key 'normal (kbd "K") #'my/eglot-hover)
    (evil-local-set-key 'insert (kbd "C-c h") #'my/eglot-signature))


  (defun my--eglot-buffer-setup ()
    "Set up Yasnippet, Eldoc, and code action queries for Eglot buffers."
    (if (eglot-managed-p)
        (progn
          (yas-minor-mode 1)
          (my--eldoc-diagnostics-only)
          (my--eglot-bind-hover-keys)
          ;; Run after Eglot's didSave notification.
          (add-hook 'after-save-hook
                    #'my--eglot-query-code-actions-after-save t t)
          (add-hook 'after-change-functions
                    #'my--eglot-clear-code-action-suggestion nil t))
      (remove-hook 'after-save-hook
                   #'my--eglot-query-code-actions-after-save t)
      (remove-hook 'after-change-functions
                   #'my--eglot-clear-code-action-suggestion t)
      (yas-minor-mode -1)
      (my--eglot-clear-code-action-suggestion)))

  (add-hook 'eglot-managed-mode-hook #'my--eglot-buffer-setup))


;; @languages

(use-package cc-mode
  :straight nil
  :hook
  (c-mode . eglot-ensure)
  (c-ts-mode . eglot-ensure))

(use-package rust-mode
  :mode "\\.rs\\'"
  :hook
  (rust-mode . eglot-ensure))

(use-package zig-mode
  :mode "\\.zig\\'"
  :hook
  (zig-mode . eglot-ensure))

(use-package typescript-ts-mode
  :straight nil
  :mode (("\\.ts\\'" . typescript-ts-mode)
         ("\\.tsx\\'" . tsx-ts-mode)
         ("\\.jsx\\'" . tsx-ts-mode))
  :hook
  (typescript-ts-mode . eglot-ensure)
  (tsx-ts-mode . eglot-ensure))

(use-package js
  :straight nil
  :mode (("\\.js\\'" . js-ts-mode)
         ("\\.mjs\\'" . js-ts-mode)
         ("\\.cjs\\'" . js-ts-mode))
  :hook (js-ts-mode . eglot-ensure))

;; Web buffers: 2-space indentation (same pattern as my--c-setup).
(defun my--web-setup ()
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 2)
  (when (derived-mode-p 'typescript-ts-mode 'tsx-ts-mode)
    (setq-local typescript-ts-mode-indent-offset 2))
  (when (derived-mode-p 'js-ts-mode)
    (setq-local js-indent-level 2)))

(add-hook 'typescript-ts-mode-hook #'my--web-setup)
(add-hook 'tsx-ts-mode-hook #'my--web-setup)
(add-hook 'js-ts-mode-hook #'my--web-setup)



(add-to-list 'auto-mode-alist '("\\.env\\(\\..*\\)?\\'" . conf-unix-mode))



;; @compilation

(defun my/save-and-recompile ()
  "Save the current buffer, then rerun its compilation."
  (interactive)
  (save-buffer)
  (recompile))

(defun my--bind-compilation-keys (keymap)
  (keymap-set keymap "M-<return>" #'my/save-and-recompile))

(defun my/scale-ghostel-compilation-buffer ()
  "Render Ghostel compilation buffers at 90% of the default text size."
  (when (string-match-p
         "\\`\\*\\(?:ghostel-\\)?compilation\\(?:<[^>]+>\\)?\\*\\'"
         (buffer-name))
    (buffer-face-set '(:height 0.90))))

(my/scale-ghostel-compilation-buffer)

(add-hook 'ghostel-mode-hook #'my/scale-ghostel-compilation-buffer)
(add-hook 'ghostel-compile-view-mode-hook
          #'my/scale-ghostel-compilation-buffer)

(add-to-list
 'display-buffer-alist
 '("\\*\\(?:ghostel-\\)?compilation\\(?:<[^>]+>\\)?\\*"
   (display-buffer-reuse-window display-buffer-in-side-window)
   (side . right)
   (window-width . 0.4)))

(with-eval-after-load 'compile
  (require 'ghostel)
  (require 'ghostel-compile)
  (ghostel-compile-global-mode 1))

(with-eval-after-load 'cc-mode (my--bind-compilation-keys c-mode-map))
(with-eval-after-load 'c-ts-mode (my--bind-compilation-keys c-ts-mode-map))
(with-eval-after-load 'rust-mode (my--bind-compilation-keys rust-mode-map))
(with-eval-after-load 'rust-ts-mode (my--bind-compilation-keys rust-ts-mode-map))
(with-eval-after-load 'zig-mode (my--bind-compilation-keys zig-mode-map))
(with-eval-after-load 'go-mode (my--bind-compilation-keys go-mode-map))
(with-eval-after-load 'go-ts-mode (my--bind-compilation-keys go-ts-mode-map))
(with-eval-after-load 'typescript-ts-mode
  (my--bind-compilation-keys typescript-ts-mode-map)
  (my--bind-compilation-keys tsx-ts-mode-map))
(with-eval-after-load 'js (my--bind-compilation-keys js-ts-mode-map))

;; @prog-c

(defun my--c-setup ()
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 4)
  (setq-local eglot-ignored-server-capabilities
              (cons :documentOnTypeFormattingProvider
                    (remove :documentOnTypeFormattingProvider
                            eglot-ignored-server-capabilities)))
  (when (derived-mode-p 'c-mode)
    (setq-local c-basic-offset 4))
  (when (derived-mode-p 'c-ts-mode)
    (setq-local c-ts-mode-indent-offset 4)))

(add-hook 'c-mode-hook #'my--c-setup)
(add-hook 'c-ts-mode-hook #'my--c-setup)


;; @shells

(use-package ghostel
  :straight (ghostel :type git :host github :repo "dakra/ghostel"
                     :files ("lisp/*.el" "etc" "src" "vendor"
                             "build.zig" "build.zig.zon" "symbols.map"))
  :defer t
  :custom
  (ghostel-module-auto-install 'ask)
  (ghostel-module-directory "~/.cache/emacs/ghostel/")
  (ghostel-keymap-exceptions
   '("C-c" "C-x" "C-u" "C-h" "M-x" "M-:" "M-c" "M-j" "C-\\"
     "M-1" "M-2" "M-3" "M-4" "M-5")))

(use-package evil-ghostel
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode)
  :config
  (defun my/ghostel-history-previous ()
    "Send an up-arrow key to the terminal."
    (interactive)
    (ghostel--send-encoded "up" ""))

  (defun my/ghostel-history-next ()
    "Send a down-arrow key to the terminal."
    (interactive)
    (ghostel--send-encoded "down" ""))

  (evil-define-key* 'insert evil-ghostel-mode-map
    (kbd "C-y") #'ghostel-paste)
  (evil-define-key* '(normal insert) evil-ghostel-mode-map
    (kbd "C-p") #'tiso/fff-find-file
    (kbd "C-n") #'consult-buffer
    (kbd "M-p") #'my/ghostel-history-previous
    (kbd "M-n") #'my/ghostel-history-next)
  (evil-define-key* 'normal evil-ghostel-mode-map
    (kbd "s") #'my/leap-forward
    (kbd "S") #'my/leap-backward))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package agent-shell
  :defer t
  :custom
  (agent-shell-header-style 'text)
  (agent-shell-show-welcome-message nil)
  :preface
  (defun my/enable-evil-agent-shell ()
    "Select the appropriate Evil state for the current Agent Shell buffer."
    (evil-local-mode 1)
    (if (derived-mode-p 'agent-shell-viewport-edit-mode)
        (evil-insert-state)
      (evil-normal-state)))
  :hook
  ((agent-shell-mode
    agent-shell-viewport-view-mode
    agent-shell-viewport-edit-mode
    agent-shell-diff-mode) . my/enable-evil-agent-shell)
  :config
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (derived-mode-p 'agent-shell-mode
                            'agent-shell-viewport-view-mode
                            'agent-shell-viewport-edit-mode
                            'agent-shell-diff-mode)
        (my/enable-evil-agent-shell)))))

(defun my/shell-root ()
  "Project root if inside a project, else the current directory."
  (require 'project)
  (if-let* ((project (project-current)))
      (project-root project)
    default-directory))

(defvar my/shell-workspace-configurations nil
  "Alist mapping project roots to their most recent work layouts.")

(defvar my/shell-last-buffers nil
  "Alist mapping project roots to their most recently selected shell.")

(defun my/remember-shell-buffer (root buffer)
  "Remember BUFFER as ROOT's most recently selected shell."
  (setf (alist-get root my/shell-last-buffers nil nil #'equal) buffer))

(defun my/shell-buffer-p ()
  "Return non-nil when the current buffer is a managed shell."
  (derived-mode-p 'ghostel-mode
                  'agent-shell-mode
                  'agent-shell-viewport-view-mode
                  'agent-shell-viewport-edit-mode))

(require 'project)

(defun my/kill-non-project-buffers ()
  "Kill file, directory, and terminal buffers outside the current project."
  (interactive)
  (let* ((root (file-name-as-directory
                (project-root (project-current t))))
         buffers)
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (let ((path (or buffer-file-name default-directory)))
          (when (and path
                     (or buffer-file-name
                         (derived-mode-p 'dired-mode
                                         'comint-mode
                                         'eshell-mode
                                         'term-mode
                                         'vterm-mode)
                         (my/shell-buffer-p))
                     (not (file-in-directory-p
                           (expand-file-name path) root)))
            (push buffer buffers)))))
    (setq buffers (nreverse buffers))
    (if (null buffers)
        (message "No non-project file, directory, or terminal buffers.")
      (when (yes-or-no-p
             (format "Kill %d buffer%s outside %s? "
                     (length buffers)
                     (if (= (length buffers) 1) "" "s")
                     root))
        (mapc #'kill-buffer buffers)
        (message "Killed %d non-project buffers." (length buffers))))))

(keymap-set project-prefix-map "K" #'my/kill-non-project-buffers)

(defun my/remember-shell-workspace ()
  "Save the current work layout for its project before opening a shell."
  (unless (my/shell-buffer-p)
    (let ((root (my/shell-root)))
      (setf (alist-get root my/shell-workspace-configurations nil nil #'equal)
            (current-window-configuration)))))

(defun my/restore-shell-workspace ()
  "Restore the saved work layout for the current shell's project."
  (interactive)
  (let* ((root (my/shell-root))
         (configuration
          (alist-get root my/shell-workspace-configurations nil nil #'equal)))
    (unless (window-configuration-p configuration)
      (user-error "No saved work layout for %s" root))
    (set-window-configuration configuration)))

(defun my/toggle-shell-workspace ()
  "Toggle between the current work layout and its project's last shell."
  (interactive)
  (if (my/shell-buffer-p)
      (my/restore-shell-workspace)
    (let* ((root (my/shell-root))
           (buffer (alist-get root my/shell-last-buffers nil nil #'equal)))
      (if (buffer-live-p buffer)
          (progn
            (my/remember-shell-workspace)
            (pop-to-buffer buffer)
            (delete-other-windows))
        (my/agent-shell-max)))))

(defun my/agent-shell-max (&optional prompt-for-agent)
  "Switch to a project shell, or choose an agent when creating one."
  (interactive "P")
  (my/remember-shell-workspace)
  (require 'agent-shell)
  (let* ((root (my/shell-root))
         (default-directory root)
         (buffer
          (or (agent-shell--shell-buffer :no-create t :no-error t)
              (agent-shell--start
               :config (if prompt-for-agent
                           (agent-shell-select-config :prompt "Start new agent: ")
                         (agent-shell-omp-make-agent-config))
               :no-focus t
               :new-session t))))
    (my/remember-shell-buffer root buffer)
    (pop-to-buffer buffer))
  (delete-other-windows))

(defun my/ghostel-slot (n)
  "Switch to or create Ghostel slot N for the current project."
  (my/remember-shell-workspace)
  (require 'ghostel)
  (let* ((root (my/shell-root))
         (default-directory root)
         (ghostel-buffer-name
          (format "*ghostel:%s:%d*" (directory-file-name root) n))
         (buffer (ghostel)))
    (my/remember-shell-buffer root buffer))
  (delete-other-windows))

(global-set-key (kbd "M-1") #'my/agent-shell-max)
(dotimes (index 4)
  (let ((slot (+ index 2)))
    (global-set-key (kbd (format "M-%d" slot))
                    (lambda ()
                      (interactive)
                      (my/ghostel-slot slot)))))
(global-set-key (kbd "M-c") #'my/toggle-shell-workspace)

(global-set-key (kbd "C-c b") #'compile)
(global-set-key (kbd "C-c r") #'recompile)
(global-set-key (kbd "<f5>") #'compile)
(global-set-key (kbd "S-<f5>") #'recompile)
