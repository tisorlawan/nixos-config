;; -*- lexical-binding: t -*-

(require 'consult)
(require 'project)
(require 'seq)

(defconst tiso/fff-directory
  (expand-file-name ".."
                    (file-name-directory (or load-file-name buffer-file-name)))
  "Root directory of this Emacs configuration.")

(defconst tiso/fff-module-source-file
  (expand-file-name "fff/tiso-fff-module.c" tiso/fff-directory))
(defconst tiso/fff-module-file
  (expand-file-name "fff/tiso-fff-module.so" tiso/fff-directory))
(defconst tiso/fff-library-file
  (expand-file-name "fff/libfff_c.so" tiso/fff-directory))
(defconst tiso/fff-install-marker-file
  (expand-file-name "fff/.installed-version" tiso/fff-directory))
(defconst tiso/fff-library-package    "@ff-labs/fff-bin-linux-x64-gnu")
(defconst tiso/fff-library-version    "0.10.5")

(defgroup tiso-fff nil
  "Fast project file and content search using FFF."
  :group 'convenience)

(defcustom tiso/fff-grep-mode 0
  "Default FFF grep mode: 0 plain, 1 regex, or 2 fuzzy."
  :type '(choice (const :tag "Plain" 0)
                 (const :tag "Regex" 1)
                 (const :tag "Fuzzy" 2))
  :group 'tiso-fff)

(defcustom tiso/fff-file-score-threshold nil
  "Minimum FFF score for file candidates, or nil to show all results."
  :type '(choice (const :tag "No threshold" nil) integer)
  :group 'tiso-fff)

(defun tiso/fff--library-url ()
  "Return the npm tarball URL for the pinned prebuilt engine."
  (let ((unscoped (file-name-nondirectory tiso/fff-library-package)))
    (format "https://registry.npmjs.org/%s/-/%s-%s.tgz"
            tiso/fff-library-package unscoped tiso/fff-library-version)))


(defun tiso/fff--require-executable (name)
  "Return executable NAME, or signal a clear setup error."
  (or (executable-find name)
      (user-error "FFF setup needs `%s', which is not in PATH" name)))


(defun tiso/fff--run (program directory &rest args)
  "Run PROGRAM with ARGS in DIRECTORY, signaling a useful error on failure."
  (let ((buffer (get-buffer-create "*tiso-fff-setup*"))
        (default-directory (file-name-as-directory (expand-file-name directory))))
    (with-current-buffer buffer
      (goto-char (point-max))
      (insert (format "\n$ %s %s\n" program (string-join args " "))))
    (let ((status (apply #'process-file program nil buffer t args)))
      (unless (eq status 0)
        (error "FFF setup command failed: %s %s\n%s"
               program (string-join args " ")
               (with-current-buffer buffer (buffer-string)))))))

(defun tiso/fff--install-marker ()
  "Return the marker identifying the pinned FFF native package."
  (format "%s@%s\n" tiso/fff-library-package tiso/fff-library-version))

(defun tiso/fff--library-current-p ()
  "Return non-nil when the installed FFF library matches the current pin."
  (and (file-exists-p tiso/fff-library-file)
       (file-exists-p tiso/fff-install-marker-file)
       (string-equal (with-temp-buffer
                       (insert-file-contents tiso/fff-install-marker-file)
                       (buffer-string))
                     (tiso/fff--install-marker))))

(defun tiso/fff--write-install-marker ()
  "Atomically record the installed FFF package version."
  (let ((temporary
         (make-temp-file
          (expand-file-name ".installed-version-"
                            (file-name-directory tiso/fff-install-marker-file)))))
    (unwind-protect
        (progn
          (with-temp-file temporary
            (insert (tiso/fff--install-marker)))
          (rename-file temporary tiso/fff-install-marker-file t))
      (when (file-exists-p temporary)
        (delete-file temporary)))))

(defun tiso/fff--emacs-module-header ()
  "Return the path to emacs-module.h, or signal an error."
  (or (locate-file "emacs-module.h"
                   (append
                    (list (expand-file-name "../include" invocation-directory)
                          (expand-file-name "../share/emacs/src" invocation-directory))
                    (split-string (or (getenv "C_INCLUDE_PATH") "") path-separator t)))
      (car (file-expand-wildcards
            (expand-file-name "../share/emacs/*/src/emacs-module.h"
                              invocation-directory)))
      (user-error "Cannot build FFF binding: emacs-module.h not found")))

(defun tiso/fff--build-module ()
  "Compile the Emacs binding module from its C source with gcc."
  (let ((gcc (tiso/fff--require-executable "gcc"))
        (header (tiso/fff--emacs-module-header))
        (output (make-temp-file
                 (expand-file-name ".tiso-fff-module-"
                                   (file-name-directory tiso/fff-module-file))
                 nil ".so")))
    (unless (file-exists-p tiso/fff-module-source-file)
      (error "FFF binding source not found: %s" tiso/fff-module-source-file))
    (unwind-protect
        (progn
          (tiso/fff--run gcc (file-name-directory tiso/fff-module-file)
                         "-Wall" "-Wextra" "-fPIC" "-shared"
                         (concat "-I" (directory-file-name (file-name-directory header)))
                         "-o" output tiso/fff-module-source-file "-ldl")
          (rename-file output tiso/fff-module-file t))
      (when (file-exists-p output)
        (delete-file output)))))


(defun tiso/fff--download-library ()
  "Download the prebuilt libfff_c.so from npm into `tiso/fff-library-file'.
The npm tarball is a plain gzip archive (`package/libfff_c.so'); fetch it
with curl and extract with tar -- no npm client required."
  (let* ((curl (tiso/fff--require-executable "curl"))
         (tar  (tiso/fff--require-executable "tar"))
         (tmp  (file-name-as-directory (make-temp-file "tiso-fff-lib" t)))
         (tgz  (expand-file-name "pkg.tgz" tmp)))
    (unwind-protect
        (progn
          (tiso/fff--run curl tmp "-fsSL" "-o" tgz (tiso/fff--library-url))
          (tiso/fff--run tar tmp "xzf" tgz)
          (let ((built (expand-file-name "package/libfff_c.so" tmp)))
            (unless (file-exists-p built)
              (error "Downloaded FFF tarball lacks libfff_c.so: %s"
                     (tiso/fff--library-url)))
            (make-directory (file-name-directory tiso/fff-library-file) t)
            (let ((destination
                   (make-temp-file
                    (expand-file-name ".libfff_c-"
                                      (file-name-directory tiso/fff-library-file))
                    nil ".so")))
              (unwind-protect
                  (progn
                    (copy-file built destination t)
                    (rename-file destination tiso/fff-library-file t))
                (when (file-exists-p destination)
                  (delete-file destination))))))
      (delete-directory tmp t))))


(defun tiso/fff-install ()
  "Explicitly provision the native FFF pieces.
Downloads the prebuilt `libfff_c.so' engine when missing and builds the
Emacs binding when missing or older than its C source."
  (interactive)
  (unless (tiso/fff--library-current-p)
    (message "FFF: downloading %s@%s ..."
             tiso/fff-library-package tiso/fff-library-version)
    (tiso/fff--download-library)
    (tiso/fff--write-install-marker)
    (message "FFF: downloaded libfff_c.so"))
  (when (or (not (file-exists-p tiso/fff-module-file))
            (file-newer-than-file-p tiso/fff-module-source-file tiso/fff-module-file))
    (message "FFF: building Emacs binding with gcc ...")
    (tiso/fff--build-module)
    (message "FFF: built %s" (file-name-nondirectory tiso/fff-module-file)))
  (message "FFF installation is ready"))

(declare-function tiso-fff-module-set-library-path "tiso-fff-module" (path))
(declare-function tiso-fff-module-search "tiso-fff-module" (root query current-file))
(declare-function tiso-fff-module-grep "tiso-fff-module" (root query mode))

;; Consult has no public API for dynamic candidate generation with previews.
;; Keep the unavoidable private API dependency confined to this adapter.
(defun tiso/fff--consult-dynamic-collection (function &rest options)
  "Return a Consult dynamic collection built by FUNCTION and OPTIONS."
  (apply #'consult--dynamic-collection function options))

(defun tiso/fff--consult-read (collection &rest options)
  "Read from dynamic COLLECTION using Consult OPTIONS."
  (apply #'consult--read collection options))

(defun tiso/fff--load-module ()
  "Load the installed module, or explain how to install it."
  (unless (featurep 'tiso-fff-module)
    (unless (and (tiso/fff--library-current-p)
                 (file-exists-p tiso/fff-module-file))
      (user-error "FFF %s is not installed; run M-x tiso/fff-install"
                  tiso/fff-library-version))
    (when (file-newer-than-file-p tiso/fff-module-source-file
                                  tiso/fff-module-file)
      (user-error "FFF module source changed; run M-x tiso/fff-install"))
    (module-load tiso/fff-module-file)
    (tiso-fff-module-set-library-path tiso/fff-library-file)))

;; lexical-binding
;; :path :name :git-status :line :column :text

(defun tiso/fff--grep-candidate (match)
  (let* ((file (plist-get match :path))
         (line (number-to-string (plist-get match :line)))
         (file-end (length file))
         (line-beg (1+ file-end))
         (line-end (+ line-beg (length line)))
         (candidate (concat file ":" line ":" (plist-get match :text))))
    (add-text-properties 0 file-end
                         `(face consult-file consult--prefix-group ,file)
                         candidate)
    (put-text-property line-beg line-end 'face 'consult-line-number candidate)
    (put-text-property 0 1 'tiso/fff-match match candidate)
    candidate))

(defun tiso/fff--grep-candidates (root input mode)
  (when (not (string-empty-p input))
    (mapcar #'tiso/fff--grep-candidate
            (tiso-fff-module-grep root input mode))))

(defun tiso/fff--grep-marker (root candidate)
  (when candidate
    (let* ((match (get-text-property 0 'tiso/fff-match candidate))
           (file (expand-file-name (plist-get match :path) root))
           (line (plist-get match :line))
           (column (plist-get match :column))
           (buffer (find-file-noselect file))
           marker)
      (with-current-buffer buffer
        (save-restriction
          (widen)
          (goto-char (point-min))
          (forward-line (1- line))
          (move-to-column (1- column))
          (setq marker (point-marker))))
      marker)))

(defun tiso/fff--grep-state (root)
  (let ((jump (consult--jump-state))
        (origin (point-marker))
        accepted)
    (lambda (action candidate)
      (when (eq action 'return)
        (setq accepted t))
      (funcall jump action
               (tiso/fff--grep-marker root candidate))
      (when (eq action 'exit)
        (unless accepted
          (consult--jump origin))
        (set-marker origin nil)))))

(defun tiso/fff--read-grep-mode ()
  (pcase (completing-read "FFF mode: " '("Plain" "Regex" "Fuzzy") nil t)
    ("Plain" 0)
    ("Regex" 1)
    ("Fuzzy" 2)))

(defun tiso/fff--grep-mode-name (mode)
  (aref ["Plain" "Regex" "Fuzzy"] mode))

(defun tiso/fff-find-file ()
  "Find a file in the current project using FFF."
  (interactive)
  (tiso/fff--load-module)
  (let* ((project (project-current t))
         (root (expand-file-name (project-root project)))
         (current-file (or buffer-file-name ""))
         (default-directory root)
         (collection
          (tiso/fff--consult-dynamic-collection
              (lambda (input)
                (mapcar
                 (lambda (item) (plist-get item :path))
                 (seq-filter
                  (lambda (item)
                    (or (null tiso/fff-file-score-threshold)
                        (>= (plist-get item :score)
                            tiso/fff-file-score-threshold)))
                  (tiso-fff-module-search root input current-file))))
            :min-input 0
            :throttle 0.004
            :debounce 0.004)))
    (find-file
     (expand-file-name
      (tiso/fff--consult-read collection
                     :prompt "FFF file: "
                     :require-match t
                     :sort nil
                     :category 'file
                     :history 'file-name-history)
      root))))

(defun tiso/fff-grep (&optional initial mode)
  "Search the current project using FFF."
  (interactive
   (let ((initial (when (use-region-p)
                    (prog1 (buffer-substring-no-properties
                            (region-beginning) (region-end))
                      (deactivate-mark)))))
     (list initial
           (when current-prefix-arg
             (tiso/fff--read-grep-mode)))))
  (tiso/fff--load-module)
  (when mode
    (setq tiso/fff-grep-mode mode))
  (unless (and (integerp tiso/fff-grep-mode)
               (<= 0 tiso/fff-grep-mode 2))
    (user-error "Invalid FFF grep mode: %S" tiso/fff-grep-mode))
  (let* ((project (project-current t))
         (root (expand-file-name (project-root project)))
         (default-directory root)
         (mode tiso/fff-grep-mode)
         (collection
          (tiso/fff--consult-dynamic-collection
              (lambda (input)
                (tiso/fff--grep-candidates root input mode))
            :min-input 1
            :throttle 0.004
            :debounce 0.004)))
    (tiso/fff--consult-read
     collection
     :prompt (format "Grep [%s]: " (tiso/fff--grep-mode-name mode))
     :require-match t
     :sort nil
     :lookup #'consult--lookup-member
     :category 'consult-grep
     :group #'consult--prefix-group
     :initial initial
     :history '(:input tiso/fff--grep-history)
     :state (tiso/fff--grep-state root))))

(provide 'tiso-fff)
