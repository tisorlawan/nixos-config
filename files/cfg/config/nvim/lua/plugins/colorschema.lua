vim.cmd([[ set background=dark ]])
vim.g.transparent = true

-- mellifluous lackluster
vim.g.colorscheme = "mellifluous"

return {
  {
    "slugbyte/lackluster.nvim",
    lazy = false,
    priority = 1000,
    init = function() end,
    config = function()
      local lackluster = require("lackluster")
      lackluster.setup({
        tweak_syntax = {
          string = "default",
          string_escape = "default",
          comment = "default",
          builtin = "default", -- builtin modules and functions
          type = "default",
          keyword = "default",
          keyword_return = "default",
          keyword_exception = "default",
        },
        tweak_background = {
          normal = "none", -- transparent
        },
      })

      if vim.g.colorscheme == "lackluster" then
        -- vim.cmd.colorscheme("lackluster-hack") -- my favorite
        -- vim.cmd.colorscheme("lackluster-mint")
        vim.cmd.colorscheme("lackluster-mint")
      end
    end,
  },
  {
    "ramojus/mellifluous.nvim",
    config = function()
      require("mellifluous").setup({
        colorset = "mountain", -- mellifluous, alduin, mountain, tender, kanagawa_dragon
        transparent_background = {
          enabled = vim.g.colorscheme,
        },
      })
      if vim.g.colorscheme == "mellifluous" then
        vim.cmd("colorscheme mellifluous")
      end
    end,
  },
}
