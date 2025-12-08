vim.cmd([[ set background=dark ]])
vim.g.transparent = true

-- mellifluous kanagawa hybrid zenwritten
vim.g.colorscheme = "zen"

return {
  {
    "rebelot/kanagawa.nvim",
    config = function()
      if vim.g.colorscheme == "kanagawa" then
        vim.cmd("colorscheme kanagawa-wave")
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
          transparent = true,
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
