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
(fringe-mode '(0 . 0))
(show-paren-mode 1) ; show matching parens
(blink-cursor-mode 1)
(column-number-mode)
(set-frame-parameter nil 'undecorated nil)


;; Backup Files Settings
(setq
 backup-by-copying t
 backup-directory-alist
 '((".*" . "~/.emacs.d/backups/"))
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)


;; set my font
(if (member "Fira Code" (font-family-list))
	(set-face-attribute 'default nil :family "Fira Code" :height 150)
  (set-face-attribute 'default nil :family "Menlo" :height 150))


(use-package atom-one-dark-theme :ensure t)
(use-package github-theme :ensure t)

;; Some Nice themes
(use-package doom-themes :ensure t
  :config
  (setq doom-themes-enable-bold t;
		doom-themes-enable-italic t)
  (doom-themes-visual-bell-config))

;; A nice modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

; needed by dashboard
(use-package page-break-lines :ensure t)


(use-package dashboard
  :ensure t
  :config
  (setq dashboard-center-content t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-set-navigator t)
  (setq dashboard-projects-backend 'project-el)
  (setq dashboard-items '((recents  . 5)
                          (projects . 5)
						  (bookmarks . 5)
                        (registers . 5)))
  (dashboard-setup-startup-hook))



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
(global-set-key (kbd "s-g") 'magit-status)


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


(use-package yasnippet :ensure t
  :hook (lsp-mode . yas-minor-mode))

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (go-mode . lsp-deferred)
  :hook (python-mode . lsp-deferred)
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
  :hook (go-mode . display-line-numbers-mode))

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

;; (use-package mini-frame
;;   :ensure t
;;   :config
;;   (mini-frame-mode)
;;   (custom-set-variables
;;   `(mini-frame-show-parameters
;;    '((top . 0.1)
;;      (width . 0.9)
;;      (left . 0.5)))))

(use-package which-key :ensure t
  :init
  (which-key-mode)
  (which-key-setup-side-window-bottom)
  (setq which-key-idle-delay 0.2)
  (setq which-key-show-remaining-keys t))

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
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#282c34" "#ff6c6b" "#98be65" "#ECBE7B" "#51afef" "#c678dd" "#46D9FF" "#bbc2cf"])
 '(awesome-tray-mode-line-active-color "#0031a9")
 '(awesome-tray-mode-line-inactive-color "#d7d7d7")
 '(blink-cursor-mode t)
 '(custom-enabled-themes '(atom-one-dark))
 '(custom-safe-themes
   '("1d78d6d05d98ad5b95205670fe6022d15dabf8d131fe087752cc55df03d88595" "9e39a8334e0e476157bfdb8e42e1cea43fad02c9ec7c0dbd5498cf02b9adeaf1" "eb122e1df607ee9364c2dfb118ae4715a49f1a9e070b9d2eb033f1cefd50a908" "08a27c4cde8fcbb2869d71fdc9fa47ab7e4d31c27d40d59bf05729c4640ce834" "18cd5a0173772cdaee5522b79c444acbc85f9a06055ec54bb91491173bc90aaa" "8feca8afd3492985094597385f6a36d1f62298d289827aaa0d8a62fe6889b33c" "2d035eb93f92384d11f18ed00930e5cc9964281915689fa035719cab71766a15" "f490984d405f1a97418a92f478218b8e4bcc188cf353e5dd5d5acd2f8efd0790" "35c096aa0975d104688a9e59e28860f5af6bb4459fd692ed47557727848e6dfe" "28a104f642d09d3e5c62ce3464ea2c143b9130167282ea97ddcc3607b381823f" "b5fff23b86b3fd2dd2cc86aa3b27ee91513adaefeaa75adc8af35a45ffb6c499" "3c2f28c6ba2ad7373ea4c43f28fcf2eed14818ec9f0659b1c97d4e89c99e091e" "d5a878172795c45441efcd84b20a14f553e7e96366a163f742b95d65a3f55d71" "5b809c3eae60da2af8a8cfba4e9e04b4d608cb49584cb5998f6e4a1c87c057c4" "1623aa627fecd5877246f48199b8e2856647c99c6acdab506173f9bb8b0a41ac" "711efe8b1233f2cf52f338fd7f15ce11c836d0b6240a18fffffc2cbd5bfe61b0" "fce3524887a0994f8b9b047aef9cc4cc017c5a93a5fb1f84d300391fba313743" "4a8d4375d90a7051115db94ed40e9abb2c0766e80e228ecad60e06b3b397acab" "f2927d7d87e8207fa9a0a003c0f222d45c948845de162c885bf6ad2a255babfd" "4bca89c1004e24981c840d3a32755bf859a6910c65b829d9441814000cf6c3d0" "2c49d6ac8c0bf19648c9d2eabec9b246d46cb94d83713eaae4f26b49a8183fc4" "cae81b048b8bccb7308cdcb4a91e085b3c959401e74a0f125e7c5b173b916bf9" "01cf34eca93938925143f402c2e6141f03abb341f27d1c2dba3d50af9357ce70" "bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" "fa2b58bb98b62c3b8cf3b6f02f058ef7827a8e497125de0254f56e373abee088" "77113617a0642d74767295c4408e17da3bfd9aa80aaa2b4eeb34680f6172d71a" "d74c5485d42ca4b7f3092e50db687600d0e16006d8fa335c69cf4f379dbd0eee" "7b3d184d2955990e4df1162aeff6bfb4e1c3e822368f0359e15e2974235d9fa8" "730a87ed3dc2bf318f3ea3626ce21fb054cd3a1471dcd59c81a4071df02cb601" "4f01c1df1d203787560a67c1b295423174fd49934deb5e6789abd1e61dba9552" "bf387180109d222aee6bb089db48ed38403a1e330c9ec69fe1f52460a8936b66" "e074be1c799b509f52870ee596a5977b519f6d269455b84ed998666cf6fc802a" "c086fe46209696a2d01752c0216ed72fd6faeabaaaa40db9fc1518abebaf700d" "c4bdbbd52c8e07112d1bfd00fee22bf0f25e727e95623ecb20c4fa098b74c1bd" "a3b6a3708c6692674196266aad1cb19188a6da7b4f961e1369a68f06577afa16" "93ed23c504b202cf96ee591138b0012c295338f38046a1f3c14522d4a64d7308" "c83c095dd01cde64b631fb0fe5980587deec3834dc55144a6e78ff91ebc80b19" "7d708f0168f54b90fc91692811263c995bebb9f68b8b7525d0e2200da9bc903c" "6084dce7da6b7447dcb9f93a981284dc823bab54f801ebf8a8e362a5332d2753" "54cf3f8314ce89c4d7e20ae52f7ff0739efb458f4326a2ca075bf34bc0b4f499" "6c3b5f4391572c4176908bb30eddc1718344b8eaff50e162e36f271f6de015ca" "7a994c16aa550678846e82edc8c9d6a7d39cc6564baaaacc305a3fdc0bd8725f" "79278310dd6cacf2d2f491063c4ab8b129fee2a498e4c25912ddaa6c3c5b621e" "74ba9ed7161a26bfe04580279b8cad163c00b802f54c574bfa5d924b99daa4b9" "d6603a129c32b716b3d3541fc0b6bfe83d0e07f1954ee64517aa62c9405a3441" "6c9cbcdfd0e373dc30197c5059f79c25c07035ff5d0cc42aa045614d3919dab4" "3df5335c36b40e417fec0392532c1b82b79114a05d5ade62cfe3de63a59bc5c6" "188fed85e53a774ae62e09ec95d58bb8f54932b3fd77223101d036e3564f9206" "6b80b5b0762a814c62ce858e9d72745a05dd5fc66f821a1c5023b4f2a76bc910" "aaa4c36ce00e572784d424554dcc9641c82d1155370770e231e10c649b59a074" "9efb2d10bfb38fe7cd4586afb3e644d082cbcdb7435f3d1e8dd9413cbe5e61fc" "5036346b7b232c57f76e8fb72a9c0558174f87760113546d3a9838130f1cdb74" "76bfa9318742342233d8b0b42e824130b3a50dcc732866ff8e47366aed69de11" "71e5acf6053215f553036482f3340a5445aee364fb2e292c70d9175fb0cc8af7" "2cdc13ef8c76a22daa0f46370011f54e79bae00d5736340a5ddfe656a767fddf" "99ea831ca79a916f1bd789de366b639d09811501e8c092c85b2cb7d697777f93" "e1ef2d5b8091f4953fe17b4ca3dd143d476c106e221d92ded38614266cea3c8b" "2f1518e906a8b60fac943d02ad415f1d8b3933a5a7f75e307e6e9a26ef5bf570" "be9645aaa8c11f76a10bcf36aaf83f54f4587ced1b9b679b55639c87404e2499" "e6ff132edb1bfa0645e2ba032c44ce94a3bd3c15e3929cdf6c049802cf059a2a" "990e24b406787568c592db2b853aa65ecc2dcd08146c0d22293259d400174e37" default))
 '(dired-listing-switches "-alop")
 '(doom-modeline-mode t)
 '(exwm-floating-border-color "#888888")
 '(fci-rule-color "#5B6268")
 '(flymake-error-bitmap '(flymake-double-exclamation-mark modus-theme-fringe-red))
 '(flymake-note-bitmap '(exclamation-mark modus-theme-fringe-cyan))
 '(flymake-warning-bitmap '(exclamation-mark modus-theme-fringe-yellow))
 '(global-display-line-numbers-mode t)
 '(global-hl-line-mode t)
 '(highlight-tail-colors '(("#aecf90" . 0) ("#c0efff" . 20)))
 '(hl-paren-background-colors '("#e8fce8" "#c1e7f8" "#f8e8e8"))
 '(hl-paren-colors '("#40883f" "#0287c8" "#b85c57"))
 '(hl-todo-keyword-faces
   '(("TODO" . "#dc752f")
	 ("NEXT" . "#dc752f")
	 ("THEM" . "#2d9574")
	 ("PROG" . "#4f97d7")
	 ("OKAY" . "#4f97d7")
	 ("DONT" . "#f2241f")
	 ("FAIL" . "#f2241f")
	 ("DONE" . "#86dc2f")
	 ("NOTE" . "#b1951d")
	 ("KLUDGE" . "#b1951d")
	 ("HACK" . "#b1951d")
	 ("TEMP" . "#b1951d")
	 ("FIXME" . "#dc752f")
	 ("XXX+" . "#dc752f")
	 ("\\?\\?\\?+" . "#dc752f")))
 '(horizontal-scroll-bar-mode nil)
 '(ibuffer-deletion-face 'modus-theme-mark-del)
 '(ibuffer-filter-group-name-face 'modus-theme-mark-symbol)
 '(ibuffer-marked-face 'modus-theme-mark-sel)
 '(ibuffer-title-face 'modus-theme-pseudo-header)
 '(jdee-db-active-breakpoint-face-colors (cons "#1B2229" "#51afef"))
 '(jdee-db-requested-breakpoint-face-colors (cons "#1B2229" "#98be65"))
 '(jdee-db-spec-breakpoint-face-colors (cons "#1B2229" "#3f444a"))
 '(line-number-mode nil)
 '(line-spacing 0.2)
 '(mini-frame-show-parameters '((top . 16) (width . 0.9) (left . 0.5)))
 '(nrepl-message-colors
   '("#032f62" "#6a737d" "#d73a49" "#6a737d" "#005cc5" "#6f42c1" "#d73a49" "#6a737d"))
 '(ns-alternate-modifier 'meta)
 '(ns-command-modifier 'super)
 '(objed-cursor-color "#ff6c6b")
 '(org-src-block-faces 'nil)
 '(package-selected-packages
   '(github-theme atom-one-dark-theme flatland-theme plan9-theme centaur-tabs modus-themes deadgrep dashboard toml-mode yaml-mode sublimity-scroll yasnippet ivy-rich which-key mini-frame mini-frame-mode emacs-mini-frame ivy-prescient company-prescient doom-modeline ido-vertical smex diminish pandoc-mode web-mode ivy-posframe fsharp-mode tree-sitter-langs tree-sitter csharp-mode go-gen-test multiple-cursors neotree evil rust-mode prescient magit counsel ivy doom-themes flycheck lsp-ui exec-path-from-shell company lsp-mode go-mode use-package))
 '(pdf-view-midnight-colors (cons "#bbc2cf" "#282c34"))
 '(rustic-ansi-faces
   ["#282c34" "#ff6c6b" "#98be65" "#ECBE7B" "#51afef" "#c678dd" "#46D9FF" "#bbc2cf"])
 '(scroll-bar-mode nil)
 '(sml/active-background-color "#98ece8")
 '(sml/active-foreground-color "#424242")
 '(sml/inactive-background-color "#4fa8a8")
 '(sml/inactive-foreground-color "#424242")
 '(tetris-x-colors
   [[229 192 123]
	[97 175 239]
	[209 154 102]
	[224 108 117]
	[152 195 121]
	[198 120 221]
	[86 182 194]])
 '(vc-annotate-background "#282c34")
 '(vc-annotate-background-mode nil)
 '(vc-annotate-color-map
   (list
	(cons 20 "#98be65")
	(cons 40 "#b4be6c")
	(cons 60 "#d0be73")
	(cons 80 "#ECBE7B")
	(cons 100 "#e6ab6a")
	(cons 120 "#e09859")
	(cons 140 "#da8548")
	(cons 160 "#d38079")
	(cons 180 "#cc7cab")
	(cons 200 "#c678dd")
	(cons 220 "#d974b7")
	(cons 240 "#ec7091")
	(cons 260 "#ff6c6b")
	(cons 280 "#cf6162")
	(cons 300 "#9f585a")
	(cons 320 "#6f4e52")
	(cons 340 "#5B6268")
	(cons 360 "#5B6268")))
 '(vc-annotate-very-old-color nil)
 '(xterm-color-names
   ["black" "#a60000" "#005e00" "#813e00" "#0031a9" "#721045" "#00538b" "gray65"])
 '(xterm-color-names-bright
   ["gray35" "#972500" "#315b00" "#70480f" "#2544bb" "#8f0075" "#30517f" "white"]))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
