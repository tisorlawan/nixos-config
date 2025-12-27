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
