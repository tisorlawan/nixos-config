return {
  "folke/trouble.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    icons = false,
  },
  config = function(_, opts)
    require("trouble").setup(opts)
    vim.keymap.set("n", "<leader>X", function()
      require("trouble").toggle("workspace_diagnostics")
    end, { desc = "workspace diagnostics" })
    vim.keymap.set("n", "<leader>x", function()
      require("trouble").toggle("document_diagnostics")
    end, { desc = "document diagnostics" })
  end,
}
