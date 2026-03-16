-- require('vim._core.ui2').enable()

vim.o.relativenumber = false
vim.o.number = false

vim.o.ignorecase = true
vim.o.smartcase = true

-- vim.o.autocomplete = true

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.linebreak = true

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.equalalways = false
vim.opt.inccommand = 'split'

vim.opt.clipboard = 'unnamedplus'

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.lazyredraw = true
vim.opt.updatetime = 300
vim.opt.ttimeoutlen = 0

vim.opt.showmatch = true
vim.opt.shortmess:append 'S'
vim.opt.title = true
vim.opt.list = true
vim.opt.listchars = {
  tab = '» ',
  trail = '·',
  nbsp = '␣',
  extends = '→',
  precedes = '←',
}
vim.opt.showbreak = '↪'

vim.opt.signcolumn = 'yes'
