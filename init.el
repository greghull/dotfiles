;;; package --- init.el
;;; Commentary:
;;; My custom Emacs config


(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))



;;; Misc cleanup settings
;;; Code:
(setq inhibit-startup-screen t )	; inhibit useless and old-school startup screen
(setq ring-bell-function 'ignore )	; silent bell when you make a mistake
(setq coding-system-for-read 'utf-8 )	; use utf-8 by default
(setq coding-system-for-write 'utf-8 )
(setq initial-scratch-message "") ; print a default message in the empty scratch buffer opened at startup
(setq mouse-autoselect-window nil) ; click to select window under mouse
(setq-default truncate-lines t) ; don't wrap lines by default
(setq-default tab-width 4) ;default tab width 4
(delete-selection-mode 1)
(defalias 'yes-or-no-p 'y-or-n-p)
(cua-selection-mode 1)

;; memory management settings
(setq read-process-output-max (* 4096 10))

;; Set gc threshhold high, but then only gc when idle
(setq gc-cons-threshold (eval-when-compile (* 1024 1024 256)))
;; only collect garbage after 2 seconds of idle activity
(run-with-idle-timer 2 t (lambda () (garbage-collect)))


;; Appearance related settings
(customize-set-variable 'scroll-bar-mode nil)
(customize-set-variable 'horizontal-scroll-bar-mode nil)
(tool-bar-mode -1)
						;(menu-bar-mode -1)
(tab-bar-mode 0)
(fringe-mode '(5 . 5))
(show-paren-mode 1) ; show matching parens
(blink-cursor-mode 1)
(column-number-mode)
(set-frame-parameter nil 'undecorated nil)


;; set my font
(if (member "Fira Code" (font-family-list))
	(set-face-attribute 'default nil :family "Fira Code" :height 150)
  (set-face-attribute 'default nil :family "Menlo" :height 150))

;; Some Nice themes
(use-package doom-themes :ensure t
  :config
  (setq doom-themes-enable-bold t
		doom-themes-enable-italic t)
  (doom-themes-visual-bell-config))

;; A nice modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))


;; Backup Files Settings
(setq
 backup-by-copying t
 backup-directory-alist
 '((".*" . "~/.emacs.d/backups/"))
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)



;; MacOS Keyboard settings
;; set special keys
(setq mac-command-modifier 'super)
(setq mac-option-modifier 'meta)

;; general operations
(global-set-key (kbd "s-n") 'make-frame-command)
(global-set-key (kbd "s-w") 'delete-frame)
(global-set-key (kbd "s-q") 'save-buffers-kill-terminal)

;; file operations
(global-set-key (kbd "s-o") 'find-file)
(global-set-key (kbd "s-s") 'save-buffer)
;; list open file buffers to switch
(global-set-key (kbd "s-b")
				'(lambda (&optional arg)
                   "runs buffer-menu but with the sense of C-u inverted (ie files-only unless C-u is given)"
                   (interactive "P")
                   (setq arg (not arg))
                   (buffer-menu arg)))
(global-set-key (kbd "s-p") 'project-find-file)


;; clipboard and selection
(global-set-key (kbd "s-x") 'kill-region)
(global-set-key (kbd "s-c") 'kill-ring-save)
(global-set-key (kbd "s-v") 'yank)
(global-set-key (kbd "s-a") 'mark-whole-buffer)

;; other
(global-set-key (kbd "s-z") 'undo)
(global-set-key (kbd "s-l") 'goto-line)



;; diminish various mode names
(use-package diminish
  :ensure t
  :config
  (diminish 'eldoc-mode))



(use-package neotree
  :ensure t
  :commands (neotree))


;; Like SublimeText and VSCode
(use-package multiple-cursors
  :ensure t
  :bind ("s-d" . 'mc/mark-next-like-this))



;; Get Macos path into emacs path
(use-package exec-path-from-shell
  :ensure t
  :init
  (when (memq window-system '(mac ns))
  (setenv "SHELL" "/bin/bash")
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-envs
   '("PATH" "GOPATH"))))


;; Git Support
(use-package magit
  :ensure t
  :commands (magit-status))


;;; Get Flycheck and LSP up and running

(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode))


(use-package yasnippet :ensure t)

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (go-mode . lsp-deferred)
  :hook (c-mode-hook . lsp-deferred))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)



;; Web stuff

(use-package web-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode)))



;; needed for pandoc-mode
(use-package hydra :ensure t)

;; Markdown stuff
(use-package pandoc-mode
  :ensure t
  :hook (markdown-mode . pandoc-mode)
  :hook (pandoc-mode . pandoc-load-default-settings))

;;; Go stuff

(use-package go-mode
  :defer t
  :ensure t
  :mode ("\\.go\\'" . go-mode)
  :hook (go-mode . electric-pair-mode)
  :hook (go-mode . linum-mode))

(defun my-go-gen-test-setup ()
  "My keybindings for generating a go test."
  (interactive)
  (local-set-key (kbd "C-c C-g") #'go-gen-test-dwim))

(use-package go-gen-test
  :ensure t
  :hook (go-mode . my-go-gen-test-setup))

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  "Format GO buffers and imports before saving."
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)



;; C++ Stuff
;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-cpp-install-save-hooks ()
  "Format C++ buffers and imports before saving."
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'cpp-mode-hook #'lsp-cpp-install-save-hooks)



;; Support for .NET stuff

(use-package tree-sitter :ensure t)
(use-package tree-sitter-langs :ensure t)


(use-package csharp-mode
  :ensure t
  :config
  :mode ("\\.cs\\'" . csharp-mode)
  :hook (csharp-mode . electric-pair-mode))


(use-package fsharp-mode
  :defer t
  :ensure t)


;; Support for .csprog files
(define-derived-mode csproj-mode xml-mode "csproj"
  "A major mode for editing csproj and other msbuild-style project files"
  :group 'csproj)

(add-to-list 'auto-mode-alist '("\\.[^.]*proj\\'" . csproj-mode))

;;Company mode is a standard completion package that works well with lsp-mode.
;;company-lsp integrates company mode completion with lsp-mode.
;;completion-at-point also works out of the box but doesn't support snippets.

(use-package company
  :ensure t
  :diminish
  :init
  (global-company-mode 1)
  :config
  (setq company-idle-delay 0.5)
  (setq company-minimum-prefix-length 3))

(use-package company-lsp
  :ensure t
  :commands company-lsp);;Optional - provides fancier overlays.



;;Setup Ivy, Counsel, Swiper, Prescient...

(use-package ivy :ensure t
  :diminish
  :config
  (setq ivy-use-virtual-buffers t)  ;; no idea, but recommended by project maintainer
  (setq enable-recursive-minibuffers t) ;; no idea, but recommended by project maintainer
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-use-selectable-prompt t)
  (define-key ivy-minibuffer-map (kbd "C-j") #'ivy-immediate-done)
  (define-key ivy-minibuffer-map (kbd "RET") #'ivy-alt-done)
  (ivy-mode 1))  ;; changes the format of the number of results

(use-package swiper :ensure t
  :config
  (global-set-key "\C-s" 'swiper))

(use-package counsel :ensure t
  :diminish
  :config
  (counsel-mode 1))

(use-package prescient
  :ensure t
  :config
  (prescient-persist-mode +1))

(use-package ivy-prescient
  :ensure t
  :config
  (ivy-prescient-mode +1))

(use-package company-prescient
  :ensure t
  :config
  (company-prescient-mode +1))

(use-package mini-frame
  :ensure t
  :config
  (mini-frame-mode)
  (custom-set-variables
  `(mini-frame-show-parameters
   '((top . 0.7)
     (width . 0.9)
     (left . 0.5)))))

(use-package which-key :ensure t
  :init
  (which-key-mode)
  (setq which-key-show-early-on-C-h t)
  (setq which-key-popup-type 'side-window)
  (which-key-setup-side-window-right-bottom))

(use-package ivy-rich :ensure t
  :init
  (ivy-rich-mode 1)
  (setq ivy-rich-path-style 'abbrev)
  (setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line))


;;; custom functions
(defun insert-current-date (&optional omit-day-of-week-p)
    "Insert today's date using the current locale.
  With a prefix argument, the date is inserted without the day of
  the week."
    (interactive "P*")
    (insert (calendar-date-string (calendar-current-date) nil
								  omit-day-of-week-p)))


;; For smooth scrolling
    ;; scroll one line at a time (less "jumpy" than defaults)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time


(use-package yaml-mode :ensure t)

(use-package toml-mode :ensure t)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(doom-one))
 '(custom-safe-themes
   '("d74c5485d42ca4b7f3092e50db687600d0e16006d8fa335c69cf4f379dbd0eee" "7b3d184d2955990e4df1162aeff6bfb4e1c3e822368f0359e15e2974235d9fa8" "730a87ed3dc2bf318f3ea3626ce21fb054cd3a1471dcd59c81a4071df02cb601" "4f01c1df1d203787560a67c1b295423174fd49934deb5e6789abd1e61dba9552" "bf387180109d222aee6bb089db48ed38403a1e330c9ec69fe1f52460a8936b66" "e074be1c799b509f52870ee596a5977b519f6d269455b84ed998666cf6fc802a" "c086fe46209696a2d01752c0216ed72fd6faeabaaaa40db9fc1518abebaf700d" "c4bdbbd52c8e07112d1bfd00fee22bf0f25e727e95623ecb20c4fa098b74c1bd" "a3b6a3708c6692674196266aad1cb19188a6da7b4f961e1369a68f06577afa16" "93ed23c504b202cf96ee591138b0012c295338f38046a1f3c14522d4a64d7308" "c83c095dd01cde64b631fb0fe5980587deec3834dc55144a6e78ff91ebc80b19" "7d708f0168f54b90fc91692811263c995bebb9f68b8b7525d0e2200da9bc903c" "6084dce7da6b7447dcb9f93a981284dc823bab54f801ebf8a8e362a5332d2753" "54cf3f8314ce89c4d7e20ae52f7ff0739efb458f4326a2ca075bf34bc0b4f499" "6c3b5f4391572c4176908bb30eddc1718344b8eaff50e162e36f271f6de015ca" "7a994c16aa550678846e82edc8c9d6a7d39cc6564baaaacc305a3fdc0bd8725f" "79278310dd6cacf2d2f491063c4ab8b129fee2a498e4c25912ddaa6c3c5b621e" "74ba9ed7161a26bfe04580279b8cad163c00b802f54c574bfa5d924b99daa4b9" "d6603a129c32b716b3d3541fc0b6bfe83d0e07f1954ee64517aa62c9405a3441" "6c9cbcdfd0e373dc30197c5059f79c25c07035ff5d0cc42aa045614d3919dab4" "3df5335c36b40e417fec0392532c1b82b79114a05d5ade62cfe3de63a59bc5c6" "188fed85e53a774ae62e09ec95d58bb8f54932b3fd77223101d036e3564f9206" "6b80b5b0762a814c62ce858e9d72745a05dd5fc66f821a1c5023b4f2a76bc910" "aaa4c36ce00e572784d424554dcc9641c82d1155370770e231e10c649b59a074" "9efb2d10bfb38fe7cd4586afb3e644d082cbcdb7435f3d1e8dd9413cbe5e61fc" "5036346b7b232c57f76e8fb72a9c0558174f87760113546d3a9838130f1cdb74" "76bfa9318742342233d8b0b42e824130b3a50dcc732866ff8e47366aed69de11" "71e5acf6053215f553036482f3340a5445aee364fb2e292c70d9175fb0cc8af7" "2cdc13ef8c76a22daa0f46370011f54e79bae00d5736340a5ddfe656a767fddf" "99ea831ca79a916f1bd789de366b639d09811501e8c092c85b2cb7d697777f93" "e1ef2d5b8091f4953fe17b4ca3dd143d476c106e221d92ded38614266cea3c8b" "2f1518e906a8b60fac943d02ad415f1d8b3933a5a7f75e307e6e9a26ef5bf570" "be9645aaa8c11f76a10bcf36aaf83f54f4587ced1b9b679b55639c87404e2499" "e6ff132edb1bfa0645e2ba032c44ce94a3bd3c15e3929cdf6c049802cf059a2a" "990e24b406787568c592db2b853aa65ecc2dcd08146c0d22293259d400174e37" default))
 '(dired-listing-switches "-alop")
 '(horizontal-scroll-bar-mode nil)
 '(mini-frame-show-parameters '((top . 0.7) (width . 0.9) (left . 0.5)))
 '(ns-alternate-modifier 'meta)
 '(ns-command-modifier 'super)
 '(package-selected-packages
   '(toml-mode yaml-mode sublimity-scroll yasnippet ivy-rich which-key mini-frame mini-frame-mode emacs-mini-frame ivy-prescient company-prescient doom-modeline ido-vertical smex diminish pandoc-mode web-mode ivy-posframe fsharp-mode tree-sitter-langs tree-sitter csharp-mode go-gen-test multiple-cursors neotree evil rust-mode prescient magit counsel ivy doom-themes flycheck lsp-ui exec-path-from-shell company-lsp company lsp-mode go-mode use-package))
 '(scroll-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
