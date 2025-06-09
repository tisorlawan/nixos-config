vim.cmd([[ set background=dark ]])
vim.g.transparent = true

-- mellifluous kanagawa hybrid kanagawabones zenwritten
vim.g.colorscheme = "mellifluous"

return {
  {
    "ramojus/mellifluous.nvim",
    config = function()
      require("mellifluous").setup({
        colorset = "kanagawa_dragon", -- mellifluous, alduin, mountain, tender, kanagawa_dragon
        transparent_background = {
          enabled = vim.g.colorscheme,
        },
      })
      if vim.g.colorscheme == "mellifluous" then
        vim.cmd("colorscheme mellifluous")
      end
    end,
  },

  {
    "rebelot/kanagawa.nvim",
    config = function()
      if vim.g.colorscheme == "kanagawa" then
        vim.cmd("colorscheme kanagawa")
      end
    end,
  },

  {
    "zenbones-theme/zenbones.nvim",
    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
    -- In Vim, compat mode is turned on as Lush only works in Neovim.
    dependencies = "rktjmp/lush.nvim",
    lazy = false,
    priority = 1000,
    -- you can set set configuration options here
    config = function()
      --     vim.g.zenbones_darken_comments = 45
      if vim.g.colorscheme == "kanagawabones" then
        vim.cmd.colorscheme("kanagawabones")
      end
      if vim.g.colorscheme == "zenwritten" then
        vim.cmd("colorscheme zenwritten")
      end
    end,
  },

  {
    "HoNamDuong/hybrid.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      if vim.g.colorscheme == "hybrid" then
        vim.cmd("colorscheme hybrid")
      end
    end,
  },
}
