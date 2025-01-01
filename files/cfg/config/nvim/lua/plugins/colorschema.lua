vim.cmd([[ set background=dark ]])
vim.g.transparent = true

-- no-clown-fiesta mellifluous
vim.g.colorscheme = "mellifluous"

return {
  {
    "ramojus/mellifluous.nvim",
    config = function()
      require("mellifluous").setup({
        mellifluous = {
          neutral = true,
        },
        colorset = "mellifluous", -- mellifluous, alduin, mountain, tender, kanagawa_dragon
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
