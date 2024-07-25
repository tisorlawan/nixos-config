local utils = require("utils")

vim.bo.expandtab = true
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4

utils.buf_set_keymap_add_colon()
