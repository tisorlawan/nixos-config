vim.g.rustaceanvim = {
  tools = {
    enable_clippy = false,
  },
  server = {
    default_settings = {
      ["rust-analyzer"] = {
        checkOnSave = false,
        ["check.command"] = "check",
        ["cargo.extraEnv"] = {
          ["RUSTFLAGS"] = "-C linker=clang -C link-arg=-fuse-ld=/run/current-system/sw/bin/mold",
        },
      },
    },
  },
  dap = {},
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(event)
    vim.keymap.set("n", "<C-y>", ":RustLsp flyCheck<cr>", { buffer = event.buf, silent = true })
  end,
})

return {
  "mrcjkb/rustaceanvim",
  version = "^5",
  ft = { "rust", "toml" },
  dependencies = {
    "folke/noice.nvim",
  },
}
