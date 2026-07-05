;;; packages.el -*- lexical-binding: t; -*-
;; Packages not provided by the enabled doom modules above.
;; Run `doom sync` after modifying this file.

;; base16 colorscheme — mirrors neovim's base16-nvim / base16-bright theme.
;; After install, set (setq doom-theme 'base16-bright) in config.el.
(package! base16-theme)

;; org-roam-ui — web graph view of your org-roam notes
;; Access via M-x org-roam-ui-mode (opens browser at localhost:35901)
(package! org-roam-ui)

;; nix-ts-mode — treesitter-based nix mode (better than the default nix module)
;; (package! nix-ts-mode)
