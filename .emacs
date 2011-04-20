; Loading third party code
; ------------------------
;
; we will store all our 3rd party modes here
(add-to-list 'load-path "~/.emacs.d/user-lisp/")
; some plugins (at least w3) install themselves here:
(add-to-list 'load-path "/usr/share/emacs/site-lisp")
;
; Interface
; ---------
;
; hide toolbar and scrollbar
(tool-bar-mode 0)
(scroll-bar-mode 0)
;
; show x-position (ie column number) for point in buffer
(column-number-mode 1)
;
; always highlight matching parentheses
(show-paren-mode 1)
;
; no startup screen
(setq-default inhibit-startup-screen t)
;
; always highlight line that cursor is on
(global-hl-line-mode 1)
;
; always truncate lines
(setq-default truncate-lines t)
;
; colour scheme
(require 'color-theme)
(require 'color-theme-tango)
(color-theme-tango)
;
; show file name in window title
(setq frame-title-format "%b - emacs")
;
; Clipboard
; ---------
;
; top of kill ring should also be in X clipboard
(setq x-select-enable-clipboard t)
;
; show contents of kill ring on demand
(defun show-kill-ring ()
  "Show the contents of the kill ring in a pop-up"
  (interactive)
  (popup-menu 'yank-menu))
(global-set-key "\C-cy" 'show-kill-ring)
;
; Editing conveniences
; --------------------
;
; Automatically indent the new line when we hit enter
(define-key global-map (kbd "RET") 'newline-and-indent)
;
; ido-mode -- fuzzy completion
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode)
; zap-to-char but don't delete the character itself
(defun zap-up-to-char (arg char)
  "Kill up to, but not including ARGth occurrence of CHAR.
Case is ignored if `case-fold-search' is non-nil in the current buffer.
Goes backward if ARG is negative; error if CHAR not found.
Ignores CHAR at point."
  (interactive "p\ncZap up to char: ")
  (let ((direction (if (>= arg 0) 1 -1)))
    (kill-region (point)
		 (progn
		   (forward-char direction)
		   (unwind-protect
		       (search-forward (char-to-string char) nil nil arg)
		     (backward-char direction))
		   (point)))))
; bind it to the usual zap-to-char shortcut
(global-set-key "\M-z" 'zap-up-to-char)
;
; offer recent files
(require 'recentf)
;
; get rid of `find-file-read-only' and replace it with something
; more useful.
(global-set-key (kbd "C-x C-r") 'ido-recentf-open)
;
; enable recent files mode.
(recentf-mode t)
;
; 200 files ought to be enough.
(setq recentf-max-saved-items 200)
;
(defun ido-recentf-open ()
  "Use `ido-completing-read' to \\[find-file] a recent file"
  (interactive)
  (if (find-file (ido-completing-read "Find recent file: " recentf-list))
      (message "Opening file...")
    (message "Aborting")))
;
; automatically finish quotes, brackets etc according to mode
(require 'autopair)
(autopair-global-mode)
;
; dabbrev-expand should match case
(setq dabbrev-case-fold-search nil)
;
; auto-completion with neat popup
; using dabbrev as auto-completion source
(add-to-list 'load-path "~/.emacs.d/user-lisp/auto-complete")
(require 'ac-dabbrev)
(setq ac-sources
      (list ac-source-dabbrev))
;
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/user-lisp/auto-complete/dict")
(ac-config-default)
;
; don't try to complete after semicolon (is a pain in CSS)
(setq ac-ignores '(";"))
; tab only for completion
(define-key ac-complete-mode-map "\r" nil)

;
; always spaces, never tabs
(setq-default indent-tabs-mode nil)
;
; Text formatting
; ---------------
;
; csv mode stuff, since it's used extensively in GBBO
(require 'csv-mode)
; yaml mode stuff, since google app engine uses it
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))
(add-hook 'yaml-mode-hook
	  '(lambda ()
	     (define-key yaml-mode-map "\C-m" 'newline-and-indent)))
;
; Python
; ------
;
; indent python by 4 spaces by default
(setq-default python-indent 4)
; set flymake to use pyflakes to check code (requires pyflakes installed and on $PATH)
(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
     ; Make sure it's not a remote buffer or flymake would not work
     (when (not (subsetp (list (current-buffer)) (tramp-list-remote-buffers)))
      (let* ((temp-file (flymake-init-create-temp-buffer-copy
                         'flymake-create-temp-inplace))
             (local-file (file-relative-name
                          temp-file
                          (file-name-directory buffer-file-name))))
        (list "pyflakes" (list local-file)))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pyflakes-init)))
; now always load flymake-mode with python-mode
(add-hook 'python-mode-hook 'flymake-mode)
;
; outline mode, note that the the minor mode shorcuts have an @ in them
; e.g. C-c C-c becomes C-c @ C-c
(defun py-outline-level ()
  (let (buffer-invisibility-spec)
    (save-excursion
      (skip-chars-forward "\t ")
      (current-column))))
(defun python-outline-minor-mode ()
  ; match lines with no indent and indented "class"
  ; and "def" lines.
  (setq outline-regexp "\\(def\\|class\\) ")
  ; enable our level computation
  (setq outline-level 'py-outline-level)
  ; turn on outline mode
  (outline-minor-mode t)
  ; initially hide all but the headers
  (hide-body))
; load when we open a python file
(add-hook 'python-mode-hook 'python-outline-minor-mode)
;
; JavaScript
; ----------
;
; indent JavaScript tabs (treating them as eight spaces)
(setq-default js-indent-level 8)
(add-hook 'js-mode-hook
          '(lambda ()
             (setq indent-tabs-mode t)))
;
; HTML modes / Django templates
; -----------------------------
;
; we use normal HTML mode, but add custom highlighting:
(add-to-list 'auto-mode-alist '("\\.dtml$" . html-mode))

; highlight Django templating stuff
(defvar django-tag-face (make-face 'django-tag-face))
(set-face-foreground 'django-tag-face "Orange")
;
(defvar django-variable-face (make-face 'django-variable-face))
(set-face-foreground 'django-variable-face "Green")


(defvar django-comment-face (make-face 'django-comment-face))
(set-face-foreground 'django-comment-face "Gray")

(font-lock-add-keywords
 'html-mode
 '(("\\({%[^%]*%}\\)" 1 django-tag-face prepend)
   ("\\({{[^}]*}}\\)" 1 django-variable-face prepend)
   ("\\({#[^}]*#}\\)" 1 django-comment-face prepend)
   ))
;
; django template tags
(define-skeleton template-tag-skeleton
  "Insert a {% foo %} template tag"
  "Template tag name: "
  "{% " str " %}")
(define-skeleton template-variable-skeleton
  "Insert a {{ foo }} template variable"
  "Template variable: "
  "{{ " str " }}")
(define-skeleton template-comment-skeleton
  "Insert a {# foo #} template variable"
  "Comment: "
  "{# " str " #}")
(global-set-key "\C-ctt" 'template-tag-skeleton)
(global-set-key "\C-ctv" 'template-variable-skeleton)
(global-set-key "\C-ctc" 'template-comment-skeleton)
;
; zen coding in HTML mode
(require 'zencoding-mode)
(add-hook 'sgml-mode-hook 'zencoding-mode) ;; Auto-start on any markup modes
;
; indent html with tabs only
(add-hook 'html-mode-hook
  (function
   (lambda ()
     (progn
       (setq indent-tabs-mode t)
       (setq sgml-basic-offset 8)))))
; indent django html similarly
(setq django-indent-width 8)
(setq sgml-basic-offset 8)
(setq indent-tabs-mode t)
; indent CSS with tabs also
(add-hook 'css-mode-hook
          (function
           (lambda ()
             (progn
               (setq css-indent-offset 8)
               (setq indent-tabs-mode t)))))

; better git handling
; note that you will still need to install magit.info manually
(require 'magit)

; clojure mode and other lisp necessities
(require 'clojure-mode)
(autoload 'enable-paredit-mode "paredit"
  "Turn on pseudo-structural editing of Lisp code."
  t)
(add-hook 'clojure-mode-hook 'enable-paredit-mode)

; markdown mode
(autoload 'markdown-mode "markdown-mode.el"
   "Major mode for editing Markdown files" t)
(setq auto-mode-alist
   (cons '("\\.md" . markdown-mode) auto-mode-alist))

; deleting files should go to recycle bin
(setq delete-by-moving-to-trash t)

; something in the above has switched on debugging. Switch it off.
; TODO: find offending code
(setq debug-on-error nil)