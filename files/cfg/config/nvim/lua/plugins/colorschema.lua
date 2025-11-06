vim.cmd([[ set background=dark ]])
vim.g.transparent = true

-- mellifluous kanagawa hybrid zenwritten
vim.g.colorscheme = "kanagawa"

return {
  {
    "webhooked/kanso.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      if vim.g.colorscheme == "kanso" then
        local color_mode = vim.env.COLOR

        if not color_mode then
          local color_file = vim.fn.expand("~/.color")
          if vim.fn.filereadable(color_file) == 1 then
            local lines = vim.fn.readfile(color_file)
            if #lines > 0 then
              color_mode = vim.trim(lines[1])
            end
          end
        end

        if color_mode == "light" then
          vim.cmd("colorscheme kanso-pearl")
        else
          vim.cmd("colorscheme kanso-ink")
        end
      end
    end,
  },
  {
    "aktersnurra/no-clown-fiesta.nvim",
    config = function()
      require("no-clown-fiesta").setup({
        theme = "dark", -- supported themes are: dark, dim, light
        transparent = false, -- Enable this to disable the bg color
        styles = {
          -- You can set any of the style values specified for `:h nvim_set_hl`
          comments = {},
          functions = {},
          keywords = {},
          lsp = {},
          match_paren = {},
          type = {},
          variables = {},
        },
      })
      if vim.g.colorscheme == "ncf" then
        vim.cmd("colorscheme no-clown-fiesta")
      end
    end,
  },
  -- {
  --   "ramojus/mellifluous.nvim",
  --   config = function()
  --     require("mellifluous").setup({
  --       colorset = "kanagawa_dragon", -- mellifluous, alduin, mountain, tender, kanagawa_dragon
  --       transparent_background = {
  --         enabled = vim.g.colorscheme,
  --       },
  --     })
  --     if vim.g.colorscheme == "mellifluous" then
  --       vim.cmd("colorscheme mellifluous")
  --     end
  --   end,
  -- },
  --
  {
    "rebelot/kanagawa.nvim",
    config = function()
      if vim.g.colorscheme == "kanagawa" then
        vim.cmd("colorscheme kanagawa-wave")
      end
    end,
  },
  --
  -- {
  --   "HoNamDuong/hybrid.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   opts = {},
  --   config = function()
  --     if vim.g.colorscheme == "hybrid" then
  --       vim.cmd("colorscheme hybrid")
  --     end
  --   end,
  -- },
}
