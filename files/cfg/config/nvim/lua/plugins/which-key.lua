return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  tag = "v3.8.0",
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
  config = function()
    require("which-key").setup()
    require("which-key").add({
      { "<leader>d", group = "[D]ocument" },
      { "<leader>r", group = "[R]ename" },
      { "<leader>f", group = "[F]zf search" },
      { "<leader>g", group = "[G]it" },
      { "<leader>w", group = "[W]orkspace" },
      { "<leader>t", group = "[T]oggle" },
      { "<leader>l", group = "Lazy|Lsp" },
      { "<leader>z", group = "Fold" },
    })

    require("which-key").add({
      { "<leader>h", group = "Git [H]unk", mode = "v" },
    })
  end,
}
