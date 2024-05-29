--[[
vim.g.rustaceanvim = {
  tools = {
    reload_workspace_from_cargo_toml = false,
  },
  server = {
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = false,
      },
    },
  },
  dap = {},
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    if vim.bo.filetype == "rust" then
      vim.cmd.RustLsp({ "flyCheck", "run" })
    end
  end,
})
--]]

return {
  "mrcjkb/rustaceanvim",
  version = "^4",
  ft = { "rust" },
}
