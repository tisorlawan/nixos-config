return {
  'dmtrKovalenko/fff.nvim',
  build = function()
    require('fff.download').download_or_build_binary()
  end,
  opts = { prompt = '| ' },
  keys = {
    {
      '<C-p>',
      function()
        require('fff').find_files()
      end,
      desc = 'Open file picker',
    },
    {
      '<leader>sg',
      function()
        require('fff').live_grep()
      end,
      desc = 'Live grep',
    },
    {
      '<leader>fz',
      function()
        require('fff').live_grep {
          grep = {
            modes = { 'fuzzy', 'plain' },
          },
        }
      end,
      desc = 'Fuzzy live grep',
    },
  },
}
