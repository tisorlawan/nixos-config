return {
  "smoka7/multicursors.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvimtools/hydra.nvim" },
  opts = {},
  keys = {
    {
      mode = { "v", "n" },
      "<Leader>m",
      "<Cmd>MCstart<CR>",
      desc = "Create a selection for word under the cursor",
    },
  },
}
