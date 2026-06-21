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

-- Oil file explorer
map("n", "-", "<cmd>Oil<cr>", { desc = "Open Oil file explorer" })

-- Quick config reload
map("n", "<leader>x", "<cmd>source %<CR>", { desc = "Source current file" })
