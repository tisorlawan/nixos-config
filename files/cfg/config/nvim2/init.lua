vim.g.mapleader = " "
vim.cmd.colorscheme("habamax")

------------------
---- @KEYMAPS ----
------------------
vim.keymap.set("n", "<leader>so", ":source %<cr>", {desc = "Source the current file", silent=true})
vim.keymap.set("n", "<leader>w", ":update<cr>", {desc = "Update file"})
vim.keymap.set("n", "<c-l>", "<c-w>l")
vim.keymap.set("n", "<c-h>", "<c-w>h")
vim.keymap.set("n", "<c-j>", "<c-w>j")
vim.keymap.set("n", "<c-k>", "<c-w>k")
vim.keymap.set("n", "<leader>fr", ":find **/*", {desc = "Find file recursively"})

------------------
---- @OPTIONS ----
------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"
vim.opt.wildignore = { "*.o", "*.a", "__pycache__", "*.pyc", "node_modules" }
vim.opt.breakindent = true
vim.opt.wrap = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { space = " ", trail = "•", tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.scrolloff = 8
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.virtualedit = "block"

vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "#990000", fg = "#ffffff" })
local function show_trailing_whitespace()
  if vim.bo.filetype ~= "" and vim.bo.filetype ~= "help" then
    vim.fn.matchadd("TrailingWhitespace", "\\s\\+$")
  end
end
vim.api.nvim_create_autocmd({
  "BufWinEnter",
  "FileType",
  "InsertLeave"
}, {
  pattern = "*",
  callback = show_trailing_whitespace,
})
