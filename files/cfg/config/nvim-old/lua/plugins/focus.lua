return {
  "cdmill/focus.nvim",
  cmd = { "Focus", "Zen", "Narrow" },
  keys = {
    {
      "<leader>zz",
      "<CMD>Zen<CR>",
      desc = "Zen",
    },
  },
  opts = {
    zen = {
      opts = {
        statuscolumn = " ",
      },
    },
  },
}
