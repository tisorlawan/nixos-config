return {
  'dmtrKovalenko/fff.nvim',
  commit = 'eecb795a0e14082f4b0c66e6ad80d82da49632ad',
  build = function()
    require('fff.download').download_or_build_binary()
  end,
  -- build = "nix run .#release",
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
