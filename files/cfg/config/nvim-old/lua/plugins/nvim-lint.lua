local used_ft = require("config.used_ft")

return {
  "mfussenegger/nvim-lint",
  event = "VeryLazy",
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = used_ft.linters_by_ft

    lint.linters.shellcheck.args = { "--shell=bash", "--format=json", "--external-sources", "-" }
    local function doLint()
      if vim.bo.buftype ~= "" then
        return
      end

      require("lint").try_lint()
    end

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = doLint,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "AutoSaveWritePost",
      callback = doLint,
    })

    doLint()
  end,
}
