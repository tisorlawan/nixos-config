vim.pack.add {
  'https://codeberg.org/andyg/leap.nvim',
}

vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-backward)')

local leap = require 'leap'

leap.opts.safe_labels = 'tyuofghjklvbn'
leap.opts.labels = 'sfnjklhowembuyvrgtqpcxz/SFNJKLHOWEIMBUYVRGTAQPCXZ'
