vim.pack.add { 'https://github.com/folke/trouble.nvim' }

require('trouble').setup {
  modes = {
    cascade = {
      mode = 'diagnostics',
      filter = function(items)
        local severity = vim.diagnostic.severity.HINT
        for _, item in ipairs(items) do
          severity = math.min(severity, item.severity)
        end
        return vim.tbl_filter(function(item)
          return item.severity == severity
        end, items)
      end,
    },
  },
}

vim.keymap.set('n', '<leader>xx', '<cmd>Trouble cascade<cr>', { desc = 'Cascade diagnostics (Trouble)' })
