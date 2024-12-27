vim.cmd([[ set background=dark ]])
vim.g.transparent = true

-- no-clown-fiesta tokyonight-moon
vim.g.colorscheme = "no-clown-fiesta"

return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {},
    config = function()
      require("tokyonight").setup({
        transparent = vim.g.transparent,
      })
      if vim.g.colorscheme == "tokyonight" then
        vim.cmd.colorscheme("tokyonight-moon")
      end
    end,
  },
  {
    "aktersnurra/no-clown-fiesta.nvim",
    priority = 1000,
    config = function()
      require("no-clown-fiesta").setup({
        transparent = vim.g.transparent,
      })

      if vim.g.colorscheme == "no-clown-fiesta" then
        vim.cmd.colorscheme("no-clown-fiesta")
      end
    end,
  },
}
