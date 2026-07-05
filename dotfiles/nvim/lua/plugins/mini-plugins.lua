return {
  -- Disable snacks dashboard so it doesn't conflict with mini.starter on startup.
  {
    "folke/snacks.nvim",
    opts = { dashboard = { enabled = false } },
  },

  -- Override mini.starter opts (LazyExtras ui.mini-starter handles the setup).
  {
    "echasnovski/mini.starter",
    opts = {
      footer = "welcome",
      items = {
        { name = "Edit new buffer", action = "enew", section = "Commands" },
        { name = "Terminal", action = "terminal", section = "Commands" },
        { name = "Files", action = "FzfLua files", section = "Files" },
        { name = "Recent Files", action = "FzfLua oldfiles", section = "Files" },
      },
    },
  },
}
