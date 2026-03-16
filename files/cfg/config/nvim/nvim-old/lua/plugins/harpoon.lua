return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    {
      '<leader>oa',
      function()
        local harpoon = require 'harpoon'
        harpoon:list():add()
      end,
      desc = 'Harpoon add',
    },
    {
      '<leader>or',
      function()
        local harpoon = require 'harpoon'
        local file = vim.api.nvim_buf_get_name(0)

        if file == '' then
          vim.notify 'No file'
          return
        end

        harpoon:list():remove()
      end,
      desc = 'Harpoon remove',
    },
    {
      '<leader>oe',
      function()
        local harpoon = require 'harpoon'
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = 'Harpoon menu',
    },
    {
      '<leader>om',
      function()
        local harpoon = require 'harpoon'
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = 'Harpoon menu',
    },
    {
      '<leader>1',
      function()
        local harpoon = require 'harpoon'
        harpoon:list():select(1)
      end,
      desc = 'Harpoon 1',
    },
    {
      '<leader>2',
      function()
        local harpoon = require 'harpoon'
        harpoon:list():select(2)
      end,
      desc = 'Harpoon 2',
    },
    {
      '<leader>3',
      function()
        local harpoon = require 'harpoon'
        harpoon:list():select(3)
      end,
      desc = 'Harpoon 3',
    },
    {
      '<leader>4',
      function()
        local harpoon = require 'harpoon'
        harpoon:list():select(4)
      end,
      desc = 'Harpoon 4',
    },
    {
      '<leader>5',
      function()
        local harpoon = require 'harpoon'
        harpoon:list():select(5)
      end,
      desc = 'Harpoon 5',
    },
  },
  config = function()
    local harpoon = require 'harpoon'
    local extensions = require 'harpoon.extensions'

    harpoon:setup {
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      },
    }

    harpoon:extend(extensions.builtins.highlight_current_file())
  end,
}
