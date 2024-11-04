return {
  "saecki/live-rename.nvim",
  event = { "BufReadPost", "BufNewFile" },
  keys = {
    {
      "<leader>rn",
      function()
        require("live-rename").rename()
      end,
      silent = true,
      desc = "Rename",
    },
  },
}
