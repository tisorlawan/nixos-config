return {
  {
    "rebelot/kanagawa.nvim",
    enabled = false,
    priority = 0,
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
      vim.cmd.colorscheme("kanagawa-wave")
    end,
  },
  {
    "slugbyte/lackluster.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    init = function()
      vim.cmd.colorscheme("lackluster-hack")
      -- vim.cmd.colorscheme("lackluster-hack") -- my favorite
      -- vim.cmd.colorscheme("lackluster-mint")
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    -- enabled = false,
    opts = {},
    config = function()
      require("tokyonight").setup({})
      vim.cmd.colorscheme("tokyonight-night")
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
    enabled = false,
    branch = "master",
    priority = 1000,
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
