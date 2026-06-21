return {
  -- Disable snacks dashboard so it doesn't conflict with mini.starter on startup.
  {
    "folke/snacks.nvim",
    opts = { dashboard = { enabled = false } },
  },

  {
    "nvim-mini/mini.starter",
    version = false, -- semver tags are not reliable for mini.starter; use HEAD
    -- Use event = "VimEnter" so mini.starter loads during the VimEnter phase,
    -- after all lazy=false plugins (including snacks) are fully set up. This
    -- avoids the "vim/shared.lua: expected table, got nil" error that occurs
    -- when mini.starter sets up too early and vim.tbl_deep_extend receives a
    -- nil H.default_config argument during H.setup_config.
    event = "VimEnter",
    opts = {
      -- autoopen = true is the default; mini.starter opens on VimEnter via its
      -- own nested autocmd created inside setup().
      footer = "welcome",
      items = {
        { name = "Edit new buffer", action = "enew", section = "Commands" },
        { name = "Terminal", action = "terminal", section = "Commands" },
        { name = "Files", action = "FzfLua files", section = "Files" },
        { name = "Recent Files", action = ":Telescope oldfiles", section = "Files" },
      },
    },
    config = function(_, opts)
      -- If the Lazy UI is open (lazy.nvim installing plugins), close it and
      -- re-open it after mini.starter is ready, matching LazyVim's pattern.
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "MiniStarterOpened",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      local starter = require("mini.starter")
      starter.setup(opts)
    end,
  },
}
