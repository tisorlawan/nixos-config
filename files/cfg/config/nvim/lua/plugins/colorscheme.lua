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
    enabled = false,
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
        -- vim.cmd.colorscheme("kanagawa-dragon")
      end

      fn()
      set_keymap_toggle_transparency(fn)
    end,
  },
  -- { "blazkowolf/gruber-darker.nvim" },
  {
    "aktersnurra/no-clown-fiesta.nvim",
    priority = 10,
    config = function()
      local fn = function()
        require("no-clown-fiesta").setup({
          transparent = vim.g.transparent, -- Enable this to disable the bg color
          styles = {
            comments = {},
            keywords = {},
            functions = {},
            variables = {},
            type = { bold = true },
            lsp = { underline = true },
          },
        })
        vim.cmd.colorscheme("no-clown-fiesta")
      end

      fn()
      set_keymap_toggle_transparency(fn)
    end,
  },
}
