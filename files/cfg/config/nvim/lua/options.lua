vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
-- vim.opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.updatetime = 200 -- Save swap file and trigger CursorHold
vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

vim.opt.foldlevel = 99
if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.smoothscroll = true
  vim.opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
  vim.opt.foldmethod = "expr"
  vim.opt.foldtext = ""
else
  vim.opt.foldmethod = "indent"
  vim.opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
end
