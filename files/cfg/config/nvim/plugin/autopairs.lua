vim.pack.add { 'https://github.com/windwp/nvim-autopairs' }

require('nvim-autopairs').setup {
  disable_filetype = {
    'TelescopePrompt',
    'spectre_panel',
    'lisp',
    'scheme',
  },
}
