return {
  {
    "rebelot/kanagawa.nvim",
    priority = 0,
    enabled = true,
    config = function()
      require("kanagawa").setup({
        undercurl = true,
        commentStyle = { italic = false },
        keywordStyle = { italic = false },
        statementStyle = { bold = false },
        transparent = vim.g.transparent,
        dimInactive = false,
        terminalColors = true,
      })
      vim.cmd.colorscheme("kanagawa")
    end,
  },
  { "aktersnurra/no-clown-fiesta.nvim" },
  { "kyazdani42/blue-moon" },
  { "fcancelinha/nordern.nvim", branch = "master", priority = 1000 },
  { "olivercederborg/poimandres.nvim" },
}
