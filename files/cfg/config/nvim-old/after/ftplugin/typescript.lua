local utils = require("utils")
local set = vim.opt_local

set.expandtab = true
set.tabstop = 2
set.shiftwidth = 2

utils.buf_set_keymap_add_colon()
