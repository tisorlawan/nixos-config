return {
  {
    "rebelot/kanagawa.nvim",
    priority = 0,
    -- enabled = false,
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
      vim.cmd.colorscheme("kanagawa-dragon")
    end,
  },
  {
    "aktersnurra/no-clown-fiesta.nvim",
    enabled = false,
    config = function()
      vim.cmd.colorscheme("no-clown-fiesta")
    end,
  },
  {
    "kyazdani42/blue-moon",
    enabled = false,
    config = function()
      vim.cmd.colorscheme("blue-moon")
    end,
  },
  {
    "fcancelinha/nordern.nvim",
    branch = "master",
    priority = 1000,
    enabled = false,
    config = function()
      vim.cmd.colorscheme("nordern")
    end,
  },
  {
    "olivercederborg/poimandres.nvim",
    enabled = false,
    config = function()
      vim.cmd.colorscheme("poimandres")
    end,
  },
}
