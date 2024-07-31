vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

vim.opt.cmdheight = 1

vim.opt.statuscolumn = "%s%=%{v:virtnum < 1 ? (v:relnum ? v:relnum : v:lnum < 10 ? v:lnum . ' ' : v:lnum) : ''}%="
vim.opt.signcolumn = "yes"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

vim.opt.wrap = false

vim.opt.clipboard = "unnamedplus"

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undodir = vim.fn.expand("$HOME/.undodir")
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.swapfile = false

vim.opt.virtualedit = "block" -- for better visual block

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = false
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.inccommand = "split"

vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 5

vim.opt.hlsearch = true

-- Wildignore for better experience
vim.opt.wildignorecase = true
vim.opt.wildignore:append("**/node_modules/*")
vim.opt.wildignore:append("**/.git/*")
vim.opt.wildignore:append("**/build/*")
vim.opt.wildignore:append("**/sqlx/*")

vim.o.foldcolumn = "1" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
