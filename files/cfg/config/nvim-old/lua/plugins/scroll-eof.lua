return {
  "Aasim-A/scrollEOF.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("scrollEOF").setup()
  end,
}
