local utils = require("utils")
local map = vim.keymap.set

map("n", "<esc>", "<cmd>nohlsearch<cr>")
map("n", "<m-n>", "<cmd>bnext<cr>")
map("n", "<m-p>", "<cmd>bprevious<cr>")

map("n", "'", "`")
map("n", "`", "'")

map("v", "x", '"_dP')

map("n", "gp", "`[v`]", { desc = "reselect pasted text" })
map({ "n", "v" }, "mp", '"0p', { desc = "paste from 0 register" })
map("n", "n", "nzzzv", { desc = "keep cursor centered" })
map("n", "N", "Nzzzv", { desc = "keep cursor centered" })
map("n", "<M-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<M-k>", ":m .-2<CR>==", { desc = "Move line up" })
map("v", "<M-j>", ":m '>+1<CR>gv=gv", { desc = "Move Line Down in Visual Mode" })
map("v", "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move Line Up in Visual Mode" })
map("v", "<leader>s", ":s/\\%V", { desc = "Search only in visual selection using %V atom" })
map("v", "<leader>r", '"hy:%s/\\v<C-r>h//g<left><left>', { desc = "change selection" })
map("i", "<c-p>", function()
  require("fzf-lua").registers()
end, { remap = true, silent = false, desc = " and paste register in insert mode" })
map("n", "<leader>yf", ":%y<cr>", { desc = "yank current file to the clipboard buffer" })
map("n", "<leader>xc", ":!chmod +x %<cr>", { desc = "make file executable" })
map(
  "n",
  "<leader>pf",
  ':let @+ = expand("%:p")<cr>:lua print("Copied path to: " .. vim.fn.expand("%:p"))<cr>',
  { desc = "Copy current file name and path", silent = false }
)
map(
  "n",
  "<leader>pn",
  ':let @+ = expand("%:.")<cr>:lua print("Copied relative path: " .. vim.fn.expand("%:."))<cr>',
  { desc = "Copy current file path relative to cwd", silent = false }
)
-- map("n", "<leader>tt", ":vsp term://", { desc = "Open vertical terminal split" })

map("n", "<c-s>", ":update<cr>", { silent = true })
map("i", "<c-s>", "<esc>:update<cr>", { silent = true })
map("n", "<leader>w", ":update<cr>", { silent = true })
map("n", "<leader><tab>", "<C-^>", { desc = "Alternative Buffer" })

map("n", "<leader>ps", ":Lazy<cr>", { desc = "Lazy", silent = true })
map("n", "<leader>pp", ":Lazy profile<cr>", { desc = "Profile", silent = true })

map("n", "<Leader>pt", utils.get_linters, { desc = "lint progress", silent = true })
map("n", "<Leader>pi", ":LspInfo<cr>", { desc = "lsp info", silent = true })
map("n", "<Leader>pr", ":LspRestart<cr>", { desc = "lsp restart", silent = true })
map("n", "<Leader>pm", ":Mason<cr>", { desc = "Mason", silent = true })
map("n", "<Leader>pc", ":ConformInfo<cr>", { desc = "conform info", silent = true })
map("n", "<Leader>ud", utils.toggle_diagnostics, { desc = "toggle diagnostics" })

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
-- map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
-- map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

map("n", "cn", ":cnext<CR>", { silent = true })
map("n", "cp", ":cprev<CR>", { silent = true })
map("n", "co", ":copen<CR>", { silent = true })
map("n", "cq", utils.close_diagnostics, { desc = "close diagnostics", silent = true })
map("n", "cu", utils.jumps_to_qf, { desc = "jumps to qf", silent = true })

map("i", "<c-l>", "<right>")
map("i", "<c-h>", "<left>")
map("i", "<c-j>", "<down>")
map("i", "<c-k>", "<up>")
map("i", "<m-h>", "<esc>I")
map("i", "<m-l>", "<end>")
