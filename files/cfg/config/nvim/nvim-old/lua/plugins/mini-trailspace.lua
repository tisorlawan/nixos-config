return {
  'echasnovski/mini.trailspace',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {},
  config = function(_, opts)
    require('mini.trailspace').setup(opts)

    local function set_highlight()
      vim.api.nvim_set_hl(0, 'MiniTrailspace', { link = 'DiagnosticError' })
    end

    set_highlight()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('UserTrailspaceColor', { clear = true }),
      callback = set_highlight,
    })
  end,
}
