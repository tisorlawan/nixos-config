return {
  'kovisoft/slimv',
  enabled = require('config.shared').get_used_filetypes().enabled.lisp == true,
  ft = { 'lisp' },
  init = function()
    vim.g.slimv_keybindings = 0
    vim.g.slimv_unmap_cr = 1
    vim.g.slimv_unmap_tab = 1
    vim.g.slimv_unmap_space = 1
    vim.g.paredit_mode = 0
    vim.g.paredit_electric_return = 0
  end,
}
