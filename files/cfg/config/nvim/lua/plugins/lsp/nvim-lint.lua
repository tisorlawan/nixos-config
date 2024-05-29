local m = require("plugins.lsp.config")

return {
  "mfussenegger/nvim-lint",
  event = "VeryLazy",
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = m.linters_by_ft

    lint.linters.shellcheck.args = { "--shell=bash", "--format=json", "--external-sources", "-" }
    local function doLint()
      if vim.bo.buftype ~= "" then
        return
      end
      require("lint").try_lint()
    end

    -- vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave", "TextChanged", "FocusGained" }, {
    --   callback = doLint,
    -- })

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = doLint,
    })

    -- due to auto-save.nvim, we need the custom event "AutoSaveWritePost"
    -- instead of "BufWritePost" to trigger linting to prevent race conditions
    vim.api.nvim_create_autocmd("User", {
      pattern = "AutoSaveWritePost",
      callback = doLint,
    })

    doLint() -- run on initialization
  end,
}
