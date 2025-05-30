vim.cmd([[ set background=dark ]])
vim.g.transparent = true

-- mellifluous kanagawa hybrid
vim.g.colorscheme = "kanagawa"

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
