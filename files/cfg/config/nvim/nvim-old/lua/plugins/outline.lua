return {
  'hedyhli/outline.nvim',
  config = function()
    vim.keymap.set('n', '<leader>fo', '<cmd>Outline<CR>', { desc = 'Toggle outline' })
    require('outline').setup {}
  end,
}
