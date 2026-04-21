return {
  -- Disable snacks dashboard so it doesn't conflict with mini.starter on startup.
  -- Without this, both try to open as the startup screen (snacks on UIEnter,
  -- mini.starter on VimEnter), corrupting buffer state and producing
  -- "vim/shared.lua: expected table, got nil" from vim.tbl_deep_extend.
  {
    "folke/snacks.nvim",
    opts = { dashboard = { enabled = false } },
  },

  {
    "nvim-mini/mini.starter",
    version = false, -- semver tags are not reliable for mini.starter; use HEAD
    lazy = false,
    priority = 1000,
    opts = {
      footer = "welcome",
      items = {
        { name = "Edit new buffer", action = "enew", section = "Commands" },
        { name = "Terminal", action = "terminal", section = "Commands" },
        { name = "Files", action = "FzfLua files", section = "Files" },
        { name = "Recent Files", action = ":Telescope oldfiles", section = "Files" },
      },
    },
  },
}
