return {
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        undercurl = true,
        commentStyle = { italic = false },
        keywordStyle = { italic = false },
        statementStyle = { bold = false },
      })
      -- vim.cmd.colorscheme("kanagawa-wave")
    end,
  },
  {
    "slugbyte/lackluster.nvim",
    priority = 10000,
    opts = {
      tweak_highlight = {
        ["@keyword"] = { overwrite = false, bold = true, fg = "#ffffff" },
        ["@type"] = { overwrite = false, bold = true, fg = "#89ff89" },
        ["@function.call"] = { overwrite = false, fg = "#b0b0ff" },
        ["@function.builtin"] = { overwrite = true, fg = "#ffffff", bold = true, italic = true },
        ["@variable.parameter"] = { italic = true },
        ["DiagnosticWarn"] = { fg = "#eb9534" },
        ["DiagnosticHint"] = { fg = "#8e7bed" },
        ["@comment"] = { fg = "#707070", italic = true },
      },
    },
    init = function()
      -- vim.cmd.colorscheme("lackluster-night")
      -- vim.cmd.colorscheme("lackluster-hack") -- my favorite
      -- vim.cmd.colorscheme("lackluster-mint")
    end,
  },
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {},
    config = function()
      require("tokyonight").setup({})
      -- vim.cmd.colorscheme("tokyonight-moon")
    end,
  },
  {
    "cpwrs/americano.nvim",
    priority = 1000,
    config = function()
      require("americano").setup({
        terminal = true,
        overrides = {},
      })
      -- vim.cmd.colorscheme("americano")
      vim.cmd([[hi NonText guifg=#9eaab5 ]])
    end,
  },
  {
    "aktersnurra/no-clown-fiesta.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("no-clown-fiesta")
    end,
  },
  {
    "olivercederborg/poimandres.nvim",
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme("poimandres")
    end,
  },
}
