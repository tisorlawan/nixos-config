vim.cmd([[ set background=dark ]])
vim.g.transparent = true

-- mellifluous kanagawa hybrid zenwritten
vim.g.colorscheme = "mellifluous"

return {
  {
    "webhooked/kanso.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      if vim.g.colorscheme == "kanso" then
        vim.cmd("colorscheme kanso")
      end
    end,
  },
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
        vim.cmd("colorscheme kanagawa-wave")
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
