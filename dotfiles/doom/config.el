;;; config.el -*- lexical-binding: t; -*-

;;; Identity
(setq user-full-name "fr3d"
      user-mail-address "fonalex45@gmail.com")

;;; -----------------------------------------------------------------------
;; Theme & UI
;; base16-bright mirrors the neovim base16-nvim colorscheme.
;; base16-theme package is declared in packages.el — available after doom sync.
;; -----------------------------------------------------------------------
(setq doom-theme 'base16-bright)
(setq doom-font (font-spec :family "Iosevka Nerd Font" :size 13)
      doom-variable-pitch-font (font-spec :family "Iosevka Nerd Font" :size 13))

;; Match neovim options.lua settings
(setq display-line-numbers-type 'relative)  ; relative line numbers
(setq-default fill-column 80)               ; colorcolumn equivalent
(setq scroll-margin 8)                      ; scrolloff=8
(setq-default tab-width 2
              indent-tabs-mode nil)

;; -----------------------------------------------------------------------
;; Org-mode & Org-roam (telekasten replacement)
;; Vault: ~/fr3d/ — same directory telekasten used.
;; Keybinding reference (doom defaults under SPC n r):
;;   SPC n r f  → org-roam-node-find     (was <leader>zf find notes)
;;   SPC n r i  → org-roam-node-insert   (was <leader>zz follow/insert link)
;;   SPC n r b  → org-roam-buffer-toggle (was <leader>zb backlinks)
;;   SPC n r d t → org-roam-dailies-goto-today   (was <leader>zd)
;;   SPC n r d T → org-roam-dailies-goto-tomorrow
;;   SPC n r d c → org-roam-dailies-capture-today
;;   SPC n r t  → org-roam-tag-add        (was <leader>zt tags)
;; -----------------------------------------------------------------------
(setq org-directory "~/fr3d/")
(setq org-roam-directory "~/fr3d/")
(setq org-roam-dailies-directory "daily/")  ; ~/fr3d/daily/ — mirrors telekasten

;; Org-roam capture templates — mirrors telekasten's note + daily templates
(after! org-roam
  (setq org-roam-capture-templates
        '(("d" "default" plain
           "* %?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                               "#+title: ${title}\n#+date: %U\n#+filetags: :inbox:\n\n")
           :unnarrowed t)
          ("p" "permanent" plain
           "* %?"
           :target (file+head "permanent/%<%Y%m%d%H%M%S>-${slug}.org"
                               "#+title: ${title}\n#+date: %U\n\n")
           :unnarrowed t)))

  (setq org-roam-dailies-capture-templates
        '(("d" "default" entry
           "* %<%H:%M> %?"
           :target (file+head "%<%Y-%m-%d>.org"
                               "#+title: %<%Y-%m-%d>\n#+filetags: :daily:\n\n")))))

;; Org general settings
(after! org
  (setq org-hide-emphasis-markers t
        org-pretty-entities t
        org-ellipsis " ▾"
        org-image-actual-width '(400)))

;; -----------------------------------------------------------------------
;; LSP — use the system-provided servers from editor.nix home.packages
;; -----------------------------------------------------------------------
(after! lsp-mode
  (setq lsp-idle-delay 0.3
        lsp-log-io nil))

;; Go
(after! go-mode
  (setq gofmt-command "goimports")
  (add-hook 'go-mode-hook #'lsp-deferred))

;; Python
(after! python
  (setq python-shell-interpreter "python3"))

;; -----------------------------------------------------------------------
;; Magit — mirrors lazygit workflow
;; SPC g g → magit-status
;; SPC g b → magit-blame
;; SPC g l → magit-log
;; -----------------------------------------------------------------------
(after! magit
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; -----------------------------------------------------------------------
;; Vterm — replaces kitty-internal terminal usage within emacs
;; SPC o t → open vterm
;; -----------------------------------------------------------------------
(after! vterm
  (setq vterm-max-scrollback 20000))  ; match kitty scrollback

;; -----------------------------------------------------------------------
;; Vertico / Consult — replaces telescope
;; SPC f f   → find-file        (was telescope find_files)
;; SPC s p   → consult-ripgrep  (was telescope live_grep)
;; SPC b b   → switch-buffer    (was telescope buffers)
;; -----------------------------------------------------------------------
(after! vertico
  (setq vertico-count 15))

;; -----------------------------------------------------------------------
;; Treemacs — file tree (replaces oil.nvim sidebar usage)
;; SPC o p → treemacs-select-window
;; For oil-style directory editing use dired (- key in evil maps to dired)
;; -----------------------------------------------------------------------
(map! :n "-" #'dired-jump)  ; mirrors oil.nvim's `-` binding

;; -----------------------------------------------------------------------
;; Keybindings — mirror critical neovim keymaps.lua bindings
;; -----------------------------------------------------------------------
(map! :n "C-d" (lambda () (interactive) (evil-scroll-down nil) (evil-scroll-line-to-center nil))
      :n "C-u" (lambda () (interactive) (evil-scroll-up nil) (evil-scroll-line-to-center nil)))
