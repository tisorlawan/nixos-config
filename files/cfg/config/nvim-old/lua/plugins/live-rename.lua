return {
  "saecki/live-rename.nvim",
  event = { "BufReadPost", "BufNewFile" },
  keys = {
    {
      "<leader>cr",
      function()
        require("live-rename").rename()
      end,
      silent = true,
      desc = "Rename",
    },
  },
}
