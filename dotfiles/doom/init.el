;;; init.el -*- lexical-binding: t; -*-
;; This file controls what Doom modules are enabled and in what order they load.
;; Press 'K' on a module to view its documentation, and 'gd' to browse its directory.

(doom! :input

       :completion
       company           ; completion backend
       vertico           ; search/completion framework (replaces telescope/fzf)

       :ui
       doom              ; doom's theming
       doom-dashboard    ; splash screen
       hl-todo           ; highlight TODO/FIXME/NOTE
       modeline          ; statusline
       nav-flash         ; blink cursor line after big motions
       ophints           ; highlight region an operation acts on
       (popup +defaults) ; manage temporary windows
       unicode
       (vc-gutter +pretty)  ; vcs diff in fringe
       vi-tilde-fringe      ; tildes past EOF
       workspaces           ; tab/workspace management
       zen                  ; distraction-free writing

       :editor
       (evil +everywhere)   ; vi keybindings everywhere
       file-templates
       fold
       snippets
       word-wrap

       :emacs
       dired
       electric
       undo
       vc

       :term
       vterm             ; best terminal in emacs (requires native module)

       :checkers
       syntax            ; flycheck
       spell             ; flyspell

       :tools
       (eval +overlay)
       lookup            ; documentation lookup (replaces K in nvim)
       (lsp +peek)       ; language server protocol
       (magit +forge)    ; git porcelain (replaces lazygit / fugitive)
       make
       terraform
       tmux

       :os
       (:if IS-LINUX tty)

       :lang
       data              ; JSON, TOML, CSV
       emacs-lisp
       (go +lsp)         ; gopls on PATH from dev-tools.nix
       (markdown +grip)  ; markdown preview
       nix               ; .nix syntax + nixfmt
       (org              ; org-mode
            +roam2       ; zettelkasten (telekasten replacement)
            +journal     ; daily/weekly notes
            +pretty      ; prettified symbols
            +present)    ; org-present for slides
       (python +lsp      ; pyright on PATH from editor.nix
               +pyenv)
       (sh +lsp)         ; bash-language-server
       (terraform +lsp)  ; terraform-ls on PATH
       (web +html +css)
       yaml

       :app

       :config
       (default +bindings +smartparens))
