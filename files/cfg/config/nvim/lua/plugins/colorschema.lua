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
    enabled = false,
    opts = {},
    config = function()
      require("tokyonight").setup({})
      vim.cmd.colorscheme("tokyonight-moon")
    end,
  },
  {
    "cpwrs/americano.nvim",
    enabled = false,
    config = function()
      require("americano").setup({
        terminal = true,
        overrides = {},
      })
      vim.cmd.colorscheme("americano")
      vim.cmd([[hi NonText guifg=#9eaab5 ]])
    end,
  },
  {
    "aktersnurra/no-clown-fiesta.nvim",
    -- enabled = false,
    config = function()
      vim.cmd.colorscheme("no-clown-fiesta")
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
