return {
  'MeanderingProgrammer/render-markdown.nvim',
  enabled = require('config.shared').get_used_filetypes().enabled.markdown == true,
  ft = { 'markdown' },
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
  opts = {
    enabled = false,
  },
}
