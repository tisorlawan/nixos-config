vim.pack.add { 'https://github.com/stevearc/conform.nvim' }

local options = {
  formatters_by_ft = require('shared').get_used_filetypes().formatters_by_ft,
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
}

require('conform').setup(options)

vim.api.nvim_create_user_command('ToggleAutoFormat', function()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  print((vim.b.disable_autoformat and '-disabled-' or '-enabled-') .. ' auto format')
end, { force = true })

vim.keymap.set('n', '<leader>uf', '<cmd>ToggleAutoFormat<cr>', { desc = 'Toggle autoformat' })
vim.keymap.set('n', '<leader>ua', function()
  vim.g.disable_autocomplete = not vim.g.disable_autocomplete
  print((vim.g.disable_autocomplete and '-disabled-' or '-enabled-') .. ' autocomplete')
end, { desc = 'Toggle autocomplete' })
