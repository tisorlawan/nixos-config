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
    local hl = vim.api.nvim_set_hl

    local function apply_highlights()
      local is_dark = vim.o.bg == 'dark'
      local bg = is_dark and '#ffffff' or '#000000'
      local fg = is_dark and '#000000' or '#ffffff'

      hl(0, 'LeapMatch', { underline = true, bold = true, nocombine = true })
      hl(0, 'LeapLabel', { fg = fg, bg = bg, bold = true, nocombine = true })
      hl(0, 'LeapLabelPrimary', { fg = fg, bg = bg, bold = true, nocombine = true })
      hl(0, 'LeapLabelSecondary', { fg = fg, bg = bg, underline = true, nocombine = true })
      hl(0, 'LeapLabelSelected', { fg = fg, bg = bg, underline = true, nocombine = true })
      hl(0, 'LeapBackdrop', {})
    end

    leap.opts.safe_labels = 'tyuofghjklvbn'
    leap.opts.labels = 'sfnjklhowembuyvrgtqpcxz/SFNJKLHOWEIMBUYVRGTAQPCXZ'

    apply_highlights()

    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('custom_leap_highlights', { clear = true }),
      callback = apply_highlights,
    })
  end,
}
