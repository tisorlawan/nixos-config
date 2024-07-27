local M = {
  plugins = {
    -- {
    --   "MeanderingProgrammer/markdown.nvim",
    --   main = "render-markdown",
    --   opts = {},
    --   name = "render-markdown", -- Only needed if you have another plugin named markdown.nvim
    --   dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
    --   -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    --   -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    -- },
  },
}

vim.cmd([[
    command! -nargs=? InlynePreview lua require('plugins.langs.markdown').preview_with_inlyne(<f-args>)
]])

function M.preview_with_inlyne(theme)
  local theme_option = "--theme dark"
  local current_file = vim.fn.expand("%")

  if theme and theme ~= "" then
    theme_option = theme
  end

  local command = "inlyne " .. theme_option .. " " .. vim.fn.shellescape(current_file)

  local job_id = vim.fn.jobstart(command, {
    on_exit = function(_, _, _)
      -- Do nothing on exit
    end,
    on_stderr = function(_, data, _)
      -- if data and data ~= "" then
      --   vim.api.nvim_err_writeln("Error: " .. data)
      -- end
    end,
  })

  if job_id <= 0 then
    vim.api.nvim_err_writeln("Failed to start job")
  end
end

vim.api.nvim_set_keymap("n", "<leader>ro", ":InlynePreview<CR>", { noremap = true, silent = true })

return M
