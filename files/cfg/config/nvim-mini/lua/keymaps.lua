local utils = require("utils")
local map = vim.keymap.set

map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })
map("n", "<leader><tab>", "<C-^>", { desc = "Alternative Buffer" })

map("n", "<esc>", "<cmd>nohlsearch<cr>")

map("i", "<c-s>", "<esc>:update<cr>", { silent = true })
map("n", "<c-s>", ":update<cr>", { silent = true })
map("n", "<leader>w", ":update<cr>", { silent = true })

map("i", "<c-l>", "<right>")
map("i", "<c-h>", "<left>")
map("i", "<c-j>", "<down>")
map("i", "<c-k>", "<up>")
map("i", "<m-h>", "<esc>I")
map("i", "<m-l>", "<end>")

map("n", "cn", ":cnext<CR>", { silent = true })
map("n", "cp", ":cprev<CR>", { silent = true })
map("n", "co", ":copen<CR>", { silent = true })
map("n", "cq", utils.close_diagnostics, { desc = "close diagnostics", silent = true })
map("n", "cu", utils.jumps_to_qf, { desc = "jumps to qf", silent = true })
