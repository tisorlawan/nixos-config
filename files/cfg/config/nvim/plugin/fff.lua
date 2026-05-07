vim.pack.add { 'https://github.com/dmtrKovalenko/fff.nvim' }

vim.g.fff = {
  lazy_sync = false,
  prompt = '> ',
  debug = {
    enabled = false,
    show_scores = false,
  },
  hl = {
    border = 'FFFBorder',
    title = 'FFFTitle',
  },
  keymaps = {
    close = { '<Esc>', '<C-c>' },
  },
}

vim.keymap.set('n', '<C-p>', function()
  require('fff').find_files()
end, { desc = 'Find Files' })

vim.keymap.set('n', '<leader>sg', function()
  require('fff').live_grep()
end, { desc = 'Live Grep' })

vim.keymap.set('n', '<leader>sf', function()
  require('fff').live_grep { grep = { modes = { 'fuzzy', 'plain' } } }
end, { desc = 'Live Grep Fuzzy' })
