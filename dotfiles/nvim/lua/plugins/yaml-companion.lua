return {
  "mosheavni/yaml-companion.nvim",
  opts = {
    -- Add any options here, or leave empty to use the default settings
    -- lspconfig = {
    --   settings = { ... }
    -- },
  },
  config = function(_, opts)
    local cfg = require("yaml-companion").setup(opts)
    vim.lsp.config("yamlls", cfg)
    vim.lsp.enable("yamlls")
  end,
}
