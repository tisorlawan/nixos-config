vim.cmd([[ set background=dark ]])
vim.g.transparent = true

-- mellifluous kanagawa hybrid zenwritten
vim.g.colorscheme = "kanso"

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

        print(color_mode)
        if color_mode == "light" then
          vim.cmd("colorscheme kanso-pearl")
        else
          vim.cmd("colorscheme kanso-ink")
        end
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
  -- {
  --   "rebelot/kanagawa.nvim",
  --   config = function()
  --     if vim.g.colorscheme == "kanagawa" then
  --       vim.cmd("colorscheme kanagawa-dragon")
  --     end
  --   end,
  -- },
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
