;;; package --- init.el
;;; Commentary:
;;; My custom Emacs config

;;; Misc cleanup settings
;;; Code:
(setq delete-old-versions -1 )		; delete excess backup versions silently
(setq version-control t )		; use version control
(setq vc-make-backup-files t )		; make backups file even when in version controlled dir
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")) ) ; which directory to put backups file
(setq vc-follow-symlinks t )				       ; don't ask for confirmation when opening symlinked file
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t)) ) ;transform backups file name
(setq inhibit-startup-screen t )	; inhibit useless and old-school startup screen
(setq ring-bell-function 'ignore )	; silent bell when you make a mistake
(setq coding-system-for-read 'utf-8 )	; use utf-8 by default
(setq coding-system-for-write 'utf-8 )
(setq initial-scratch-message "") ; print a default message in the empty scratch buffer opened at startup
(setq mouse-autoselect-window nil) ; click to select window under mouse
(setq-default truncate-lines t) ; don't wrap lines by default
(setq-default tab-width 4) ;default tab width 4

;; want this on the desktop
;(setq default-frame-alist '((fullscreen . maximized)))
;; only want this on thje laptop
;(setq default-frame-alist '((undecorated . t) (fullscreen . maximized))) ; no window title for more editing space

;; maybe not needed for the emacs-mac port?
;; slow down mouse scrolling
;;(setq mouse-wheel-scroll-amount '(0.1))
;;(setq mouse-wheel-progressive-speed nil)
;;(setq scroll-margin 0
;;	  scroll-conservatively 100000
;;	  scroll-preserve-screen-position 1)

;;(toggle-scroll-bar -1)
;; disable scrollbars
(customize-set-variable 'scroll-bar-mode nil)
(customize-set-variable 'horizontal-scroll-bar-mode nil)
(tool-bar-mode -1)
					;(menu-bar-mode -1)

(fringe-mode '(5 . 5))
(delete-selection-mode 1)
(show-paren-mode 1) ; show matching parens
(blink-cursor-mode 1)

(defalias 'yes-or-no-p 'y-or-n-p)

;; some mac friendly key bindings
;;
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


;; clipboard and selection
(global-set-key (kbd "s-x") 'kill-region)
(global-set-key (kbd "s-c") 'kill-ring-save)
(global-set-key (kbd "s-v") 'yank)
(global-set-key (kbd "s-a") 'mark-whole-buffer)

;; other
(global-set-key (kbd "s-z") 'undo)



;; setup packages
(require 'package)
(setq package-enable-at-startup nil) ; tells emacs not to load any packages before starting up
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)


;; ;; Bootstrap use-package
(unless (package-installed-p 'use-package) ; unless it is already installed
  (package-refresh-contents) ; updage packages archive
  (package-install 'use-package)) ; and install the most recent version of use-package
(require 'use-package)



;; Some Nice themes
(use-package doom-themes :ensure t
  :config
  (if (display-graphic-p)
	  (progn
		(set-face-attribute 'default nil :family "Menlo" :height 140)
		(doom-themes-visual-bell-config))))




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
  :config
  (when (memq window-system '(mac ns x))
	(exec-path-from-shell-initialize)))


;; Git Support
(use-package magit
  :ensure t
  :commands (magit-status))


;;; Get Flycheck and LSP up and running

(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode))


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
  "My keybindings for generating go tests."
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
  :config
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 1))

(use-package company-lsp
  :ensure t
  :commands company-lsp);;Optional - provides fancier overlays.








;; Setup Ivy, Counsel, Swiper, Prescient...

(use-package ivy :ensure t
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
 '(package-selected-packages
   '(pandoc-mode web-mode ivy-posframe fsharp-mode tree-sitter-langs tree-sitter csharp-mode go-gen-test multiple-cursors neotree evil rust-mode selectrum-prescient prescient selectrum magit counsel ivy doom-themes flycheck lsp-ui exec-path-from-shell company-lsp company lsp-mode go-mode use-package))
 '(scroll-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
