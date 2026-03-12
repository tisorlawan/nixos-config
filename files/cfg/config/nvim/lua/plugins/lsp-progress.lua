return {
  'linrongbin16/lsp-progress.nvim',
  config = function()
    require('lsp-progress').setup {
      format = function(client_messages)
        if #vim.lsp.get_clients { bufnr = 0 } == 0 then
          return ''
        end
        if #client_messages > 0 then
          return ' ' .. table.concat(client_messages, ' ')
        end
        return '󰄬'
      end,
      client_format = function(_, spinner, series_messages)
        if #series_messages > 0 then
          return spinner
        end
      end,
    }

    local group = vim.api.nvim_create_augroup('UserLspProgressStatus', { clear = true })
    vim.api.nvim_create_autocmd('User', {
      group = group,
      pattern = 'LspProgressStatusUpdated',
      callback = require('lualine').refresh,
    })
  end,
}
