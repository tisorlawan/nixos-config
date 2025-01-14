local utils = require("utils")
local set = vim.opt_local

set.expandtab = true
set.tabstop = 4
set.shiftwidth = 4

utils.buf_set_keymap_add_colon()
