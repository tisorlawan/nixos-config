return {
  "folke/trouble.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("trouble").setup({
      icons = false,
    })

    vim.keymap.set("n", "<leader>X", function()
      require("trouble").toggle("workspace_diagnostics")
    end, { desc = "workspace diagnostics" })

    vim.keymap.set("n", "<leader>x", function()
      require("trouble").toggle("document_diagnostics")
    end, { desc = "document diagnostics" })
  end,
}
