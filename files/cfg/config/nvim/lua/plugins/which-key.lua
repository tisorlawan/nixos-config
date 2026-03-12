return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  enabled = false,
  opts = {
    preset = 'helix',
    delay = 300,
    spec = {
      { '<leader>c', group = 'code' },
      { '<leader>f', group = 'file/find' },
      { '<leader>g', group = 'git' },
      { '<leader>h', group = 'hunk' },
      { '<leader>o', group = 'harpoon/swap' },
      { '<leader>r', group = 'run' },
      { '<leader>s', group = 'search/symbol' },
      { '<leader>u', group = 'toggle' },
      { '<leader>x', group = 'file ops' },
      { '<leader>y', group = 'yank path' },
      { '<leader>z', group = 'zen' },
    },
  },
}
