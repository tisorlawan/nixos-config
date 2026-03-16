vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.python3_host_prog = vim.env.NVIM_PYTHON3_HOST_PROG

vim.g.mapleader = ' '

require 'filetypes'
require 'options'
require 'commands'
require 'autocmds'
require 'keymaps'

require 'self.whitespace'
require 'self.focus'
require 'self.undotree'
require 'self.difftool'
