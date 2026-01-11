vim.cmd([[ set background=dark ]])
vim.g.transparent = true

-- mellifluous kanagawa hybrid zenwritten
vim.g.colorscheme = "kanagawa"

return {
  {
    "rebelot/kanagawa.nvim",
    config = function()
      if vim.g.colorscheme == "kanagawa" then
        require("kanagawa").setup({
          transparent = vim.g.transparent,
          overrides = function(colors)
            local theme = colors.theme
            return {
              -- -- Minimal setup: reset common syntax groups to foreground
              -- Identifier = { fg = theme.ui.fg },
              -- Function = { fg = theme.ui.fg },
              -- Statement = { fg = theme.ui.fg },
              -- Constant = { fg = theme.ui.fg },
              -- Type = { fg = theme.ui.fg },
              -- PreProc = { fg = theme.ui.fg },
              -- Special = { fg = theme.ui.fg },
              -- Delimiter = { fg = theme.ui.fg },
              -- Operator = { fg = theme.ui.fg },
              --
              -- -- Keep Comments and Strings colored
              -- Comment = { fg = theme.syn.comment, italic = true },
              -- String = { fg = theme.syn.string },
              --
              -- -- Optional: Ensure basics like booleans/numbers are also flat if desired
              -- -- or let them fall under Constant.
              -- -- Keep Todo/Error distinct usually
            }
          end,
        })
        vim.cmd("colorscheme kanagawa-dragon")
      end
    end,
  },
  {
    "nendix/zen.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      if vim.g.colorscheme == "zen" then
        require("zen").setup({
          variant = "dark",
          transparent = vim.g.transparent,
          colors = {
            palette = {
              bg0 = "#141419",
              bg2 = "#202020",
            },
          },
        })
        vim.cmd.colorscheme("zen")
      end
    end,
  },
}
