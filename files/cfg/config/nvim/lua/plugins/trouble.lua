return {
  "folke/trouble.nvim",
  opts = {
    modes = {
      cascade = {
        mode = "diagnostics",
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
  },
  cmd = "Trouble",
  -- stylua: ignore
  keys = {
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)", },
    { "<leader>xx", "<cmd>Trouble cascade<cr>", desc = "Cascade Diagnostics (Trouble)", },
    { "<leader>co", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)", },
    { "<leader>cc", "<cmd>Trouble lsp toggle focus=false follow=false win.position=bottom<cr>", desc = "LSP Definitions / references / ... (Trouble)", },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)", },
    { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)", },
  },
}
