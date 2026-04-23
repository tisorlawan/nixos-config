local map = vim.keymap.set

if vim.g.neovide then
  vim.o.guifont = 'Berkeley Mono:h14'
  vim.g.neovide_cursor_animation_length = 0.15
  vim.g.neovide_cursor_short_animation_length = 0.015
  vim.g.neovide_scroll_animation_length = 0.05
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_cursor_cell_color_fallback = true
  vim.g.neovide_opacity = 0.88
  -- vim.g.neovide_normal_opacity = 0.85
  local default_scale = vim.g.neovide_scale_factor or 1.0
  local step = 0.1

  map('n', '<C-=>', function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + step
  end, { desc = 'Zoom in' })

  map('n', '<C-->', function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - step
  end, { desc = 'Zoom out' })

  map('n', '<C-0>', function()
    vim.g.neovide_scale_factor = default_scale
  end, { desc = 'Reset zoom' })

  map('n', '<A-i>', '<cmd>split | terminal fish<cr>i', { desc = 'Horizontal split terminal' })
end
