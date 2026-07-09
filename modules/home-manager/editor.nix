{ pkgs, lib, ... }:
{
  # -----------------------------------------------------------------------
  # Neovim — package installed by Nix, config expressed inline in Nix
  # LazyVim + lazy.nvim bootstrap; mason manages LSPs at runtime
  # LazyExtras: editor.fzf (replaces telescope), editor.neo-tree,
  #             ui.mini-starter (replaces snacks dashboard)
  # Theme: gruvbox-material dark soft
  # -----------------------------------------------------------------------
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withRuby = false;
    withPython3 = false;

    # System-level packages that LSP servers or plugins need
    extraPackages = with pkgs; [
      # Language servers (mason can also manage these; listed here for availability)
      lua-language-server
      gopls
      pyright
      terraform-ls
      yaml-language-server
      typescript-language-server
      bash-language-server

      # Tools used by plugins
      ripgrep
      fd
      tree-sitter
      gcc      # Required by nvim-treesitter to compile parsers
      nodejs   # Required by many mason-installed LSPs
    ];
  };

  # -----------------------------------------------------------------------
  # Neovim config — all Lua expressed inline in Nix (no dotfiles symlink)
  # -----------------------------------------------------------------------

  xdg.configFile."nvim/init.lua".text = ''
    -- bootstrap lazy.nvim, LazyVim and your plugins
    require("config.lazy")
  '';

  xdg.configFile."nvim/lua/config/lazy.lua".text = ''
    -- Bootstrap lazy.nvim
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
      local lazyrepo = "https://github.com/folke/lazy.nvim.git"
      local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath,
      })
      if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
          { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
          { out, "Warn" },
          { "\nPress any key to exit...", "ErrorMsg" },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
      end
    end
    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup({
      spec = {
        -- LazyVim base distribution
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        -- LazyExtras: fzf replaces telescope; mini.starter replaces snacks dashboard
        { import = "lazyvim.plugins.extras.editor.fzf" },
        { import = "lazyvim.plugins.extras.editor.neo-tree" },
        { import = "lazyvim.plugins.extras.ui.mini-starter" },
        -- User plugin specs from lua/plugins/
        { import = "plugins" },
      },
      defaults = {
        lazy = false,
        version = false,
      },
      install = {
        -- install missing plugins on startup
        missing = true,
        colorscheme = { "gruvbox-material", "habamax" },
      },
      checker = {
        enabled = true,
        notify = false,
      },
      performance = {
        rtp = {
          disabled_plugins = {
            "gzip",
            "tarPlugin",
            "tokyonight",
            "tutor",
            "zipPlugin",
          },
        },
      },
    })
  '';

  xdg.configFile."nvim/lua/config/options.lua".text = ''
    -- Options — extends LazyVim defaults
    local opt = vim.opt

    opt.relativenumber = true
    opt.number = true
    opt.wrap = false
    opt.scrolloff = 8
    opt.sidescrolloff = 8
    opt.expandtab = true
    opt.shiftwidth = 2
    opt.tabstop = 2
    opt.smartindent = true
    opt.swapfile = false
    opt.backup = false
    opt.undofile = true
    opt.hlsearch = false
    opt.incsearch = true
    opt.termguicolors = true
    opt.signcolumn = "yes"
    opt.isfname:append("@-@")
    opt.updatetime = 50
    opt.colorcolumn = "80"
  '';

  xdg.configFile."nvim/lua/config/keymaps.lua".text = ''
    -- Keymaps — extends LazyVim defaults
    local map = vim.keymap.set

    -- Keep cursor centered when scrolling
    map("n", "<C-d>", "<C-d>zz")
    map("n", "<C-u>", "<C-u>zz")

    -- Keep cursor centered when searching
    map("n", "n", "nzzzv")
    map("n", "N", "Nzzzv")

    -- Move selected lines up/down in visual mode
    map("v", "J", ":m '>+1<CR>gv=gv")
    map("v", "K", ":m '<-2<CR>gv=gv")

    -- Append next line without moving cursor
    map("n", "J", "mzJ`z")

    -- Paste without losing register contents
    map("x", "<leader>p", [["_dP]])

    -- Delete to void register
    map({ "n", "v" }, "<leader>d", [["_d]])

    -- Quick config reload
    map("n", "<leader>x", "<cmd>source %<CR>", { desc = "Source current file" })
  '';

  # ── plugins ──────────────────────────────────────────────────────────────────

  xdg.configFile."nvim/lua/plugins/color.lua".text = ''
    -- gruvbox-material dark soft
    return {
      "sainnhe/gruvbox-material",
      lazy = false,
      priority = 1000,
      config = function()
        vim.g.gruvbox_material_background = "soft"
        vim.g.gruvbox_material_foreground = "material"
        vim.g.gruvbox_material_better_performance = 1
        vim.cmd.colorscheme("gruvbox-material")
      end,
    }
  '';

  xdg.configFile."nvim/lua/plugins/disabled.lua".text = ''
    return {
      { "folke/noice.nvim",             enabled = false },
      { "rcarriga/nvim-notify",         enabled = false },
      { "catppuccin/nvim",              enabled = false },
      { "nvim-lualine/lualine.nvim",    enabled = true },
      { "folke/ts-comments.nvim",       enabled = false },
      { "folke/flash.nvim",             enabled = false },
      { "folke/persistence.nvim",       enabled = false },
      { "windwp/nvim-ts-autotag",       enabled = false },
      { "rafamadriz/friendly-snippets", enabled = true },
    }
  '';

  xdg.configFile."nvim/lua/plugins/treesitter.lua".text = ''
    return {
      {
        "nvim-treesitter/nvim-treesitter",
        opts = {
          ensure_installed = {
            "bash",
            "vimdoc",
            "html",
            "json",
            "lua",
            "markdown",
            "markdown_inline",
            "python",
            "query",
            "regex",
            "vim",
            "yaml",
            "go",
            "terraform",
          },
          -- Disable terraform treesitter on fixture files
          highlight = {
            disable = function(lang)
              local buf_name = vim.fn.expand("%")
              if lang == "terraform" and string.find(buf_name, "fixture") then
                return true
              end
            end,
          },
        },
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/mason-tools.lua".text = ''
    return {
      "mason-org/mason.nvim",
      opts = {
        ensure_installed = {
          "shellcheck",
          "shfmt",
          "flake8",
          "ansible-language-server",
          "bash-language-server",
          "css-lsp",
          "eslint-lsp",
          "html-lsp",
          "lua-language-server",
          "markdown-toc",
          "markdownlint-cli2",
          "marksman",
          "prettier",
          "pylint",
          "python-lsp-server",
          "shfmt",
          "stylua",
          "tailwindcss-language-server",
          "terraform-ls",
        },
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/mini-plugins.lua".text = ''
    return {
      -- Disable snacks dashboard so it doesn't conflict with mini.starter on startup.
      {
        "folke/snacks.nvim",
        opts = { dashboard = { enabled = false } },
      },

      -- Override mini.starter opts (LazyExtras ui.mini-starter handles the setup).
      {
        "nvim-mini/mini.starter",
        opts = {
          header = [[
.         .                                  .*%@@@@@%+.                               .
     .                      .        .      +@@@#+=+%@@@=.  .       .
                  .                       .+@@%.     :@@@:     .                     .
               .                          .%@@:       =@@*          . .      .
    .                      .              :@@@        :@@%              .
           .  .               .           :%@@.       :@@%  .             .     . .   .
               . .       .                .#@@=.      -@@*              .  .
.     .    . .      .        .             :@@%:     .%@@-        ..
                    ..      ..  .           =@@%.   .#@@*.             ..       .        .
.      .                .   =@@*-.           -@@@=.-@@@=          .:-#@@.              .
                          . =@@@@@@@@*=-:::::::#@@@@@+:::::::-+#@@@@@@@@.                   .      .
                   .    .   =@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.                     .
             .              =@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.
                            =@%*=:             =@@@@@:            .-+#%@.       .              .
            .          .                .      =@@@@@:
                                               =@@@@@:.             .
  ..              .                            =@@@@@:                     .    .       .
                                 .             =@@@@@:                                          .
.             .      .          .              =@@@@@:                 .   .
       .        .           .                  =@@@@@:                                           .
         .                .                   .=@@@@@:                         ..
                                               =@@@@@:    .          .              .
                                               =@@@@@: .                        ..
                       .     .                 =@@@@@:..    . .
                .                    .  .   .  *@@@@@-            .   .
.                   . .                       .%@@@@@+
                          .   .   .       .   :@@@@@@@.       .                                   .
                                             .#@@@@@@@*.                 .                    .
          .     .  .  .                 .   .+@@@@@@@@@-         .  .                         .
.             .              .              -@@@@@@@@@@@:                                         .
        ]],
          footer = "welcome",
          items = {
            { name = "Edit new buffer", action = "enew",              section = "Commands" },
            { name = "Terminal",        action = "terminal",           section = "Commands" },
            { name = "Files",           action = "FzfLua files",      section = "Files" },
            { name = "Recent Files",    action = "FzfLua oldfiles",   section = "Files" },
          },
        },
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/markdown-preview.lua".text = ''
    return {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      build = "cd app && yarn install",
      init = function()
        vim.g.mkdp_filetypes = { "markdown" }
      end,
      ft = { "markdown" },
    }
  '';

  xdg.configFile."nvim/lua/plugins/clip.lua".text = ''
    return {
      "TobinPalmer/pastify.nvim",
      cmd = { "Pastify", "PastifyAfter" },
      config = function()
        require("pastify").setup({})
      end,
    }
  '';

  xdg.configFile."nvim/lua/plugins/yaml-companion.lua".text = ''
    return {
      "mosheavni/yaml-companion.nvim",
      opts = {},
      config = function(_, opts)
        local cfg = require("yaml-companion").setup(opts)
        vim.lsp.config("yamlls", cfg)
        vim.lsp.enable("yamlls")
      end,
    }
  '';

  xdg.configFile."nvim/lua/plugins/vim-terraform.lua".text = ''
    return { "hashivim/vim-terraform", lazy = false }
  '';

  xdg.configFile."nvim/lua/plugins/markview.lua".text = ''
    return { "OXY2DEV/markview.nvim", lazy = true }
  '';

  xdg.configFile."nvim/lua/plugins/termcolor.lua".text = ''
    return { "sekhat/termcolors.nvim" }
  '';

  xdg.configFile."nvim/lua/plugins/oil.lua".text = ''
    return {
      { "stevearc/oil.nvim", enabled = false },
    }
  '';

  xdg.configFile."nvim/lua/plugins/z.lua".text = ''
    local vault = vim.fn.expand("~/notes")

    local M = {}

    local function uuid() return os.date("%Y%m%d%H%M") end
    local function rfc3339() return os.date("%Y-%m-%dT%H:%M:%SZ") end

    local function read_template(name)
      local path = vault .. "/templates/" .. name
      local f = io.open(path, "r")
      if not f then return nil end
      local s = f:read("*a"); f:close(); return s
    end

    local function fill_template(content, title)
      local id = uuid()
      return (content
        :gsub("{{title}}", title)
        :gsub("{{uuid}}", id)
        :gsub("{{rfc3339}}", rfc3339())), id
    end

    local function write_and_open(path, content)
      local f = io.open(path, "w")
      if not f then
        vim.notify("Cannot create: " .. path, vim.log.levels.ERROR); return
      end
      f:write(content); f:close()
      vim.cmd("edit " .. vim.fn.fnameescape(path))
    end

    local function open_or_create(filename, template_name, title)
      local path = vault .. "/" .. filename
      if vim.fn.filereadable(path) == 0 then
        local tmpl = read_template(template_name) or "# " .. title .. "\n\n"
        local content = fill_template(tmpl, title)
        write_and_open(path, content)
      else
        vim.cmd("edit " .. vim.fn.fnameescape(path))
      end
    end

    local function from_template(template_name, prompt_text)
      local title = vim.fn.input(prompt_text)
      if title == "" then return end
      local tmpl = read_template(template_name) or "# {{title}}\n\n"
      local content, id = fill_template(tmpl, title)
      write_and_open(vault .. "/" .. id .. ".md", content)
    end

    -- ── pickers ──────────────────────────────────────────────────────────────────

    function M.find_notes()
      require("fzf-lua").files({ cwd = vault, prompt = "Notes> " })
    end

    function M.search_notes()
      require("fzf-lua").live_grep({ cwd = vault, prompt = "Search> " })
    end

    function M.goto_today()
      open_or_create(os.date("%Y-%m-%d") .. ".md", "daily.md", os.date("%Y-%m-%d"))
    end

    function M.goto_thisweek()
      local week = os.date("%Y-W%V")
      open_or_create(week .. ".md", "weekly.md", week)
    end

    function M.follow_link()
      local line = vim.api.nvim_get_current_line()
      local col  = vim.api.nvim_win_get_cursor(0)[2] + 1
      local link, pos = nil, 1
      while true do
        local s, e, target = line:find("%[%[(.-)%]%]", pos)
        if not s then break end
        if col >= s and col <= e then link = target; break end
        pos = e + 1
      end
      if not link then
        vim.notify("No [[wiki link]] under cursor", vim.log.levels.WARN); return
      end

      local matches = vim.fn.globpath(vault, "**/*" .. vim.fn.escape(link, "[]()") .. "*.md", false, true)
      if #matches == 0 then
        local tmpl = read_template("note.md") or "# {{title}}\n\n"
        local content, id = fill_template(tmpl, link)
        write_and_open(vault .. "/" .. id .. ".md", content)
      elseif #matches == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(matches[1]))
      else
        require("fzf-lua").fzf_exec(matches, {
          prompt = "Follow link> ",
          actions = {
            ["default"] = function(selected)
              if selected and selected[1] then
                vim.cmd("edit " .. vim.fn.fnameescape(selected[1]))
              end
            end,
          },
        })
      end
    end

    function M.new_note()  from_template("note.md", "Note title: ") end
    function M.new_poem()  from_template("poem.md", "Poem title: ") end

    function M.show_backlinks()
      local name = vim.fn.expand("%:t:r")
      if name == "" then vim.notify("No file open", vim.log.levels.WARN); return end
      require("fzf-lua").grep({
        cwd    = vault,
        search = "\\[\\[" .. name,
        no_esc = true,
        prompt = "Backlinks> ",
      })
    end

    function M.insert_link()
      require("fzf-lua").files({
        cwd    = vault,
        prompt = "Insert link> ",
        actions = {
          ["default"] = function(selected)
            if not selected or #selected == 0 then return end
            local name = vim.fn.fnamemodify(selected[1], ":t:r")
            local link = "[[" .. name .. "]]"
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { link })
            vim.api.nvim_win_set_cursor(0, { row, col + #link })
          end,
        },
      })
    end

    function M.insert_img_link()
      require("fzf-lua").files({
        cwd    = vault .. "/media/images",
        prompt = "Insert image> ",
        actions = {
          ["default"] = function(selected)
            if not selected or #selected == 0 then return end
            local name = vim.fn.fnamemodify(selected[1], ":t")
            local link = "![" .. name .. "](media/images/" .. name .. ")"
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { link })
            vim.api.nvim_win_set_cursor(0, { row, col + #link })
          end,
        },
      })
    end

    function M.show_tags()
      local tag_files = {}

      -- Pass 1: inline  tags: [tag1, tag2]
      local inline = vim.fn.systemlist(
        "rg --with-filename -o 'tags: \\[[^\\]]+\\]' "
        .. vim.fn.shellescape(vault)
        .. " --glob='*.md' --glob='!templates/*.md' 2>/dev/null"
      )
      for _, line in ipairs(inline) do
        local path, inner = line:match("^(.-):tags: %[(.-)%]$")
        if inner then
          for tag in inner:gmatch("[^,]+") do
            tag = tag:match("^%s*(.-)%s*$")
            if tag ~= "" then
              tag_files[tag] = tag_files[tag] or {}
              tag_files[tag][path] = true
            end
          end
        end
      end

      -- Pass 2: multi-line list items in frontmatter (line <= 15)
      local multiline = vim.fn.systemlist(
        "rg --vimgrep '^\\s+- [a-zA-Z0-9_/-]+$' "
        .. vim.fn.shellescape(vault)
        .. " --glob='*.md' --glob='!templates/*.md' 2>/dev/null"
      )
      for _, line in ipairs(multiline) do
        local path, lnum, tag = line:match("^(.-):(%d+):%d+:%s+%-%s+(.-)%s*$")
        if path and tag ~= "" and tonumber(lnum) <= 15 then
          tag_files[tag] = tag_files[tag] or {}
          tag_files[tag][path] = true
        end
      end

      local entries, tag_map = {}, {}
      for tag, paths in pairs(tag_files) do
        local files = vim.tbl_keys(paths)
        local label = string.format("%-32s (%d notes)", tag, #files)
        entries[#entries + 1] = label
        tag_map[label] = files
      end
      table.sort(entries)

      if #entries == 0 then
        vim.notify("No tags found in vault", vim.log.levels.WARN); return
      end

      require("fzf-lua").fzf_exec(entries, {
        prompt = "Tags> ",
        actions = {
          ["default"] = function(selected)
            if not selected or #selected == 0 then return end
            local files = tag_map[selected[1]]
            if not files then return end
            if #files == 1 then
              vim.cmd("edit " .. vim.fn.fnameescape(files[1]))
            else
              require("fzf-lua").fzf_exec(files, {
                prompt = "Tagged notes> ",
                actions = {
                  ["default"] = function(sel)
                    if sel and sel[1] then vim.cmd("edit " .. vim.fn.fnameescape(sel[1])) end
                  end,
                },
              })
            end
          end,
        },
      })
    end

    function M.panel()
      local cmds = {
        { "Find notes",   M.find_notes },
        { "Search notes", M.search_notes },
        { "Today's note", M.goto_today },
        { "Weekly note",  M.goto_thisweek },
        { "New note",     M.new_note },
        { "New poem",     M.new_poem },
        { "Follow link",  M.follow_link },
        { "Show tags",    M.show_tags },
        { "Backlinks",    M.show_backlinks },
        { "Insert link",  M.insert_link },
        { "Insert image", M.insert_img_link },
      }
      local labels = vim.tbl_map(function(c) return c[1] end, cmds)
      require("fzf-lua").fzf_exec(labels, {
        prompt = "Zettelkasten> ",
        actions = {
          ["default"] = function(selected)
            if not selected or #selected == 0 then return end
            for _, c in ipairs(cmds) do
              if c[1] == selected[1] then c[2](); return end
            end
          end,
        },
      })
    end

    -- ── plugin spec ──────────────────────────────────────────────────────────────

    return {
      {
        "ibhagwan/fzf-lua",
        optional = true,
        keys = {
          { "<leader>z",  function() M.panel() end,           desc = "Zettelkasten panel" },
          { "<leader>zf", function() M.find_notes() end,      desc = "Find notes" },
          { "<leader>zs", function() M.search_notes() end,    desc = "Search notes" },
          { "<leader>zd", function() M.goto_today() end,      desc = "Today's note" },
          { "<leader>zw", function() M.goto_thisweek() end,   desc = "Weekly note" },
          { "<leader>zz", function() M.follow_link() end,     desc = "Follow [[link]]" },
          { "<leader>zn", function() M.new_note() end,        desc = "New note" },
          { "<leader>za", function() M.new_note() end,        desc = "New templated note" },
          { "<leader>zp", function() M.new_poem() end,        desc = "New poem" },
          { "<leader>zb", function() M.show_backlinks() end,  desc = "Backlinks" },
          { "<leader>zt", function() M.show_tags() end,       desc = "Tag browser" },
          { "<leader>zI", function() M.insert_img_link() end, desc = "Insert image link" },
          { "<leader>zl", function() M.insert_link() end,     desc = "Insert [[link]]" },
        },
      },
    }
  '';

  # Remove lazy.nvim on every activation so it re-clones fresh and can never
  # get stuck in a bad git checkout state (e.g. "untracked files would be
  # overwritten by checkout"). The bootstrap in lua/config/lazy.lua re-clones
  # it automatically on the next nvim launch.
  home.activation.clearLazyNvim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -rf "$HOME/.local/share/nvim/lazy/lazy.nvim"
  '';
}
