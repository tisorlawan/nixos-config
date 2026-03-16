vim.pack.add {
  {
    src = 'https://github.com/ThePrimeagen/harpoon',
    version = 'harpoon2',
  },
}

local harpoon = require 'harpoon'

vim.keymap.set('n', '<leader>oa', function()
  local harpoon = require 'harpoon'
  harpoon:list():add()
end, { desc = 'Harpoon add' })
vim.keymap.set('n', '<leader>or', function()
  local harpoon = require 'harpoon'
  local file = vim.api.nvim_buf_get_name(0)

  if file == '' then
    vim.notify 'No file'
    return
  end

  harpoon:list():remove()
end, { desc = 'Harpoon remove' })
vim.keymap.set('n', '<leader>oe', function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = 'Harpoon menu' })
vim.keymap.set('n', '<leader>om', function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = 'Harpoon menu' })
vim.keymap.set('n', '<leader>1', function()
  harpoon:list():select(1)
end, { desc = 'Harpoon 1' })
vim.keymap.set('n', '<leader>2', function()
  harpoon:list():select(2)
end, { desc = 'Harpoon 2' })
vim.keymap.set('n', '<leader>3', function()
  harpoon:list():select(3)
end, { desc = 'Harpoon 3' })
vim.keymap.set('n', '<leader>4', function()
  harpoon:list():select(4)
end, { desc = 'Harpoon 4' })
vim.keymap.set('n', '<leader>5', function()
  harpoon:list():select(5)
end, { desc = 'Harpoon 5' })

local extensions = require 'harpoon.extensions'

harpoon:setup {
  settings = {
    save_on_toggle = true,
    sync_on_ui_close = true,
  },
}

harpoon:extend(extensions.builtins.highlight_current_file())
