return {
  'smoka7/multicursors.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = { 'nvimtools/hydra.nvim' },
  opts = {},
  keys = {
    { '<Leader>m', '<Cmd>MCstart<CR>', mode = { 'v', 'n' }, desc = 'Start multicursor selection' },
  },
}
