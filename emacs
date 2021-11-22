;; Setup packages
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Bring some sanity to backup files
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


;; clipboard and selection
(global-set-key (kbd "s-x") 'kill-region)
(global-set-key (kbd "s-c") 'kill-ring-save)
(global-set-key (kbd "s-v") 'yank)
(global-set-key (kbd "s-a") 'mark-whole-buffer)

(global-set-key (kbd "s-z") 'undo)
(global-set-key (kbd "s-f") 'isearch-forward)

(use-package expand-region
  :ensure t
  :bind ("M-<up>" . er/expand-region)
        ("M-<down>" . er/contract-region))


(kbd "m-<up>")

;; Display Settings
;; set my font
(if (member "Fira Code" (font-family-list))
    (set-face-attribute 'default nil :family "Fira Code" :height 130)
  (set-face-attribute 'default nil :family "Menlo" :height 130))

;; no scroll bars
(customize-set-variable 'scroll-bar-mode nil)
(customize-set-variable 'horizontal-scroll-bar-mode nil)
(setq-default truncate-lines 1)
(setq-default tab-width 4) ;default tab width 4
(delete-selection-mode 1)
(defalias 'yes-or-no-p 'y-or-n-p)
(cua-selection-mode 1)



;; Themes, appearance,etc...

(use-package all-the-icons
  :ensure t)

(use-package atom-one-dark-theme :ensure t)
(use-package github-theme :ensure t)
(use-package modus-themes :ensure t)


(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))



;; Project Management
(use-package projectile :ensure t
  :config
  (projectile-mode 1)
  (global-set-key (kbd "s-p") 'projectile-find-file))



;; Like SublimeText and VSCode
(use-package multiple-cursors
  :ensure t
  :bind ("s-d" . 'mc/mark-next-like-this))



;; Parenthesis related things
(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(electric-pair-mode 1)
(show-paren-mode 1)




;; Setup Clojure development stuff
(use-package company
  :ensure t
  :config
  (global-company-mode))

(use-package cider
  :ensure t
  :bind ("M-<return>" . 'cider-eval-defun-at-point))

;; (use-package clj-refactor
;;   :ensure t
;;   :config
;;   (add-hook 'clojure-mode-hook (lambda ()
;; 				 (clj-refactor-mode 1)
;; 				 (setq cljr-warn-on-eval nil)
;; 				 (cljr-add-keybindings-with-prefix "C-c C-m"))))


(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (prog-mode . lsp)
  :hook (prog-mode . display-line-numbers-mode))


;; Git Support
(use-package magit
  :ensure t
  :commands (magit-status))


;; Ivy, Swiper, Counsel, etc..

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
  (global-set-key (kbd "s-f") 'swiper)
  (global-set-key "\C-s" 'swiper))

(use-package counsel :ensure t
  :diminish
  :config
  (counsel-mode 1))

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


;; For virtual terminals
(use-package vterm :ensure t :defer t)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(custom-enabled-themes '(modus-operandi))
 '(custom-safe-themes
   '("6dc02f2784b4a49dd5a0e0fd9910ffd28bb03cfebb127a64f9c575d8e3651440" "0edb121fdd0d3b18d527f64d3e2b57725acb152187eea9826d921736bd6e409e" "f91395598d4cb3e2ae6a2db8527ceb83fed79dbaf007f435de3e91e5bda485fb" "613aedadd3b9e2554f39afe760708fc3285bf594f6447822dd29f947f0775d6c" "d47f868fd34613bd1fc11721fe055f26fd163426a299d45ce69bef1f109e1e71" "a9a67b318b7417adbedaab02f05fa679973e9718d9d26075c6235b1f0db703c8" "a7b20039f50e839626f8d6aa96df62afebb56a5bbd1192f557cb2efb5fcfb662" "b186688fbec5e00ee8683b9f2588523abdf2db40562839b2c5458fcfb322c8a4" "3d54650e34fa27561eb81fc3ceed504970cc553cfd37f46e8a80ec32254a3ec3" "0d01e1e300fcafa34ba35d5cf0a21b3b23bc4053d388e352ae6a901994597ab1" "8146edab0de2007a99a2361041015331af706e7907de9d6a330a3493a541e5a6" "fe2539ccf78f28c519541e37dc77115c6c7c2efcec18b970b16e4a4d2cd9891d" "a0be7a38e2de974d1598cf247f607d5c1841dbcef1ccd97cded8bea95a7c7639" "9b54ba84f245a59af31f90bc78ed1240fca2f5a93f667ed54bbf6c6d71f664ac" "835868dcd17131ba8b9619d14c67c127aa18b90a82438c8613586331129dda63" "246a9596178bb806c5f41e5b571546bb6e0f4bd41a9da0df5dfbca7ec6e2250c" "1704976a1797342a1b4ea7a75bdbb3be1569f4619134341bd5a4c1cfb16abad4" "d268b67e0935b9ebc427cad88ded41e875abfcc27abd409726a92e55459e0d01" "0466adb5554ea3055d0353d363832446cd8be7b799c39839f387abb631ea0995" "e8df30cd7fb42e56a4efc585540a2e63b0c6eeb9f4dc053373e05d774332fc13" "5784d048e5a985627520beb8a101561b502a191b52fa401139f4dd20acb07607" "7eea50883f10e5c6ad6f81e153c640b3a288cd8dc1d26e4696f7d40f754cc703" "7a7b1d475b42c1a0b61f3b1d1225dd249ffa1abb1b7f726aec59ac7ca3bf4dae" "171d1ae90e46978eb9c342be6658d937a83aaa45997b1d7af7657546cae5985b" "1d78d6d05d98ad5b95205670fe6022d15dabf8d131fe087752cc55df03d88595" default))
 '(fci-rule-color "#4E4E4E")
 '(horizontal-scroll-bar-mode nil)
 '(jdee-db-active-breakpoint-face-colors (cons "#D0D0E3" "#009B7C"))
 '(jdee-db-requested-breakpoint-face-colors (cons "#D0D0E3" "#005F00"))
 '(jdee-db-spec-breakpoint-face-colors (cons "#D0D0E3" "#4E4E4E"))
 '(nrepl-message-colors
   '("#183691" "#969896" "#a71d5d" "#969896" "#0086b3" "#795da3" "#a71d5d" "#969896"))
 '(objed-cursor-color "#D70000")
 '(package-selected-packages
   '(lsp-mode modus-themes doom-modeline expand-region github-theme atom-one-dark-theme vterm ivy-rich which-key counsel swiper ivy magit parinfer clj-refactor company company-mode cider rainbow-delimiters multiple-cursors projectile use-package))
 '(rustic-ansi-faces
   ["#F5F5F9" "#D70000" "#005F00" "#AF8700" "#1F55A0" "#AF005F" "#007687" "#0F1019"])
 '(scroll-bar-mode nil)
 '(tetris-x-colors
   [[229 192 123]
	[97 175 239]
	[209 154 102]
	[224 108 117]
	[152 195 121]
	[198 120 221]
	[86 182 194]]))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
