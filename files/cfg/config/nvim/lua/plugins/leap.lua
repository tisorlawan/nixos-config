return {
  'https://codeberg.org/andyg/leap.nvim',
  keys = {
    { 's', '<Plug>(leap-forward)', mode = { 'n', 'x', 'o' }, desc = 'Leap forward' },
    { 'S', '<Plug>(leap-backward)', mode = { 'n', 'x', 'o' }, desc = 'Leap backward' },
    { 'x', '<Plug>(leap-forward-till)', mode = { 'x', 'o' }, desc = 'Leap forward till' },
    { 'X', '<Plug>(leap-backward-till)', mode = { 'x', 'o' }, desc = 'Leap backward till' },
    { 'gs', '<Plug>(leap-from-window)', mode = { 'n', 'x', 'o' }, desc = 'Leap from window' },
  },
  dependencies = { 'tpope/vim-repeat' },
  config = function()
    local leap = require 'leap'
    leap.opts.safe_labels = 'tyuofghjklvbn'
    leap.opts.labels = 'sfnjklhowembuyvrgtqpcxz/SFNJKLHOWEIMBUYVRGTAQPCXZ'
  end,
}
