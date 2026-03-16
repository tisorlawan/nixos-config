vim.pack.add { 'https://github.com/hedyhli/outline.nvim' }

vim.keymap.set('n', '<leader>fo', '<cmd>Outline<CR>', { desc = 'Toggle outline' })
require('outline').setup {}
