local map = vim.keymap.set
local utils = require "utils"

map("n", "L", "<cmd>bnext<cr>")
map("n", "H", "<cmd>bprevious<cr>")

map("n", "<leader><tab>", "<C-^>", { desc = "Alternative Buffer" })

map("n", "<leader>pp", ":Lazy profile<cr>", { desc = "Profile", silent = true })

map("n", "'", "`")
map("n", "`", "'")

map("i", "<c-l>", "<right>")
map("i", "<c-h>", "<left>")

map("n", "cn", ":cnext<CR>", { silent = true })
map("n", "cp", ":cprev<CR>", { silent = true })
map("n", "co", ":copen<CR>", { silent = true })
map("n", "cq", utils.close_diagnostics, { desc = "close diagnostics", silent = true })
map("n", "cu", utils.jumps_to_qf, { desc = "jumps to qf", silent = true })

map("n", "<leader>s", ":Format<CR>:update<CR>", { desc = "Format Code", silent = true })
