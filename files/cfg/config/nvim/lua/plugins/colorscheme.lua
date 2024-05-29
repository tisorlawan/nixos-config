local function set_keymap_toggle_transparency(fn)
  vim.keymap.set("n", "<leader>ut", function()
    vim.g.transparent = not vim.g.transparent
    print("Colorscheme transparent " .. tostring(vim.g.transparent))
    fn()
  end, { silent = true, desc = "toggle transparent" })
end

vim.g.transparent = true

return {
  {
    "rebelot/kanagawa.nvim",
    priority = 0,
    config = function()
      local fn = function()
        require("kanagawa").setup({
          undercurl = true,
          commentStyle = { italic = false },
          keywordStyle = { italic = false },
          statementStyle = { bold = false },
          transparent = vim.g.transparent,
          dimInactive = false,
          terminalColors = true,
        })
        vim.cmd.colorscheme("kanagawa-wave")
      end

      fn()
      set_keymap_toggle_transparency(fn)
    end,
  },
  {
    "diegoulloao/neofusion.nvim",
    opts = {},
    config = function()
      require("neofusion").setup({
        terminal_colors = true, -- add neovim terminal colors
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true, -- invert background for search, diffs, statuslines and errors
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })
      -- vim.cmd.colorscheme("neofusion")
    end,
  },
  {
    "aktersnurra/no-clown-fiesta.nvim",
    priority = 10,
    config = function()
      local fn = function()
        require("no-clown-fiesta").setup({
          transparent = vim.g.transparent, -- Enable this to disable the bg color
          -- styles = {
          --   comments = {},
          --   keywords = {},
          --   functions = {},
          --   variables = {},
          --   type = { bold = true },
          --   lsp = { underline = true },
          -- },
        })
        -- vim.cmd.colorscheme("no-clown-fiesta")
      end

      fn()
      set_keymap_toggle_transparency(fn)
    end,
  },
}
