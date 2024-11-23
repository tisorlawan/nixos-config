local m = require("plugins.lsp.config")

return {
  "stevearc/conform.nvim",
  config = function()
    require("conform").setup({
      formatters_by_ft = m.formatters_by_ft,
      format_on_save = function(bufnr)
        if string.find(vim.fn.expand("%"), "poetry.lock") then
          return
        end

        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    })

    require("conform").formatters.ruff_fix = {
      prepend_args = { "--select", "I" },
    }

    require("conform").formatters.biome = {
      args = {
        "format",
        "--javascript-formatter-indent-width=4",
        "--indent-style=space",
        "--json-formatter-indent-style=space",
        "--json-formatter-indent-width=4",
        "--write",
        "--stdin-file-path",
        "$FILENAME",
      },
    }

    vim.api.nvim_create_user_command("ToggleAutoFormat", function()
      ---@diagnostic disable-next-line: inject-field
      vim.b.disable_autoformat = not vim.b.disable_autoformat
      if vim.b.disable_autoformat then
        print("disable auto format")
      else
        print("enabled auto format")
      end
    end, {
      desc = "disable autoformat-on-save",
      bang = true,
    })

    vim.keymap.set("n", "<leader>uf", "<cmd>ToggleAutoFormat<cr>", { desc = "toggle autoformat" })
  end,
}
