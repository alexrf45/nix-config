return {
  "RRethy/base16-nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("base16-greenscreen")
    require("base16-colorscheme").setup({
      base00 = "#000000", -- Background: true black
      base01 = "#1a1a1a", -- Lighter background (cursorline, status)
      base02 = "#333333", -- Selection background
      base03 = "#888888", -- Comments, line numbers
      base04 = "#ffffff", -- Dark foreground
      base05 = "#ffffff", -- Default foreground
      base06 = "#ffffff", -- Light foreground
      base07 = "#ffffff", -- Brightest foreground
      base08 = "#ff6b6b", -- Red (variables, errors)
      base09 = "#ffffff", -- Orange → white
      base0A = "#ffffff", -- Yellow → white
      base0B = "#ffffff", -- Green (strings) → white
      base0C = "#ffffff", -- Cyan → white
      base0D = "#ffffff", -- Blue (functions) → white
      base0E = "#ffffff", -- Magenta (keywords) → white
      base0F = "#ffffff", -- Brown/extra → white
    })
  end,
}
