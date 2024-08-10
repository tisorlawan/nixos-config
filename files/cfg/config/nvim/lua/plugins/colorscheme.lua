local function set_keymap_toggle_transparency(fn)
  vim.keymap.set("n", "<leader>ut", function()
    vim.g.transparent = not vim.g.transparent
    print("Colorscheme transparent " .. tostring(vim.g.transparent))
    fn()
  end, { silent = true, desc = "toggle transparent" })
end

vim.g.transparent = false

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
        vim.cmd.colorscheme("kanagawa-dragon")
      end

      fn()
      set_keymap_toggle_transparency(fn)
    end,
  },
  -- {
  --   "aliqyan-21/darkvoid.nvim",
  --   config = function()
  --     require("darkvoid").setup({
  --       transparent = false, -- set true for transparent
  --       glow = false, -- set true for glow effect
  --       show_end_of_buffer = true, -- set false for not showing end of buffer
  --
  --       colors = {
  --         fg = "#c0c0c0",
  --         bg = "#1c1c1c",
  --         cursor = "#bdfe58",
  --         line_nr = "#404040",
  --         visual = "#303030",
  --         comment = "#585858",
  --         string = "#d1d1d1",
  --         func = "#e1e1e1",
  --         kw = "#f1f1f1",
  --         identifier = "#b1b1b1",
  --         type = "#a1a1a1",
  --         search_highlight = "#1bfd9c",
  --         operator = "#1bfd9c",
  --         bracket = "#e6e6e6",
  --         preprocessor = "#4b8902",
  --         bool = "#66b2b2",
  --         constant = "#b2d8d8",
  --
  --         -- gitsigns colors
  --         added = "#baffc9",
  --         changed = "#ffffba",
  --         removed = "#ffb3ba",
  --
  --         -- Pmenu colors
  --         pmenu_bg = "#1c1c1c",
  --         pmenu_sel_bg = "#1bfd9c",
  --         pmenu_fg = "#c0c0c0",
  --
  --         -- EndOfBuffer color
  --         eob = "#3c3c3c",
  --
  --         -- Telescope specific colors
  --         border = "#585858",
  --         title = "#bdfe58",
  --
  --         -- bufferline specific colors
  --         -- change this to change the colors of current or selected tab
  --         bufferline_selection = "#bdfe58",
  --       },
  --     })
  --
  --     -- vim.cmd.colorscheme("darkvoid")
  --   end,
  -- },
  -- {
  --   "aktersnurra/no-clown-fiesta.nvim",
  --   priority = 10,
  --   config = function()
  --     local fn = function()
  --       require("no-clown-fiesta").setup({
  --         transparent = vim.g.transparent, -- Enable this to disable the bg color
  --         styles = {
  --           comments = {},
  --           keywords = {},
  --           functions = {},
  --           variables = {},
  --           type = { bold = true },
  --           lsp = { underline = true },
  --         },
  --       })
  --       -- vim.cmd.colorscheme("no-clown-fiesta")
  --     end
  --
  --     fn()
  --     set_keymap_toggle_transparency(fn)
  --   end,
  -- },
  -- {
  --   "vague2k/vague.nvim",
  --   config = function()
  --     require("vague").setup({
  --       -- optional configuration here
  --     })
  --   end,
  -- },
}
