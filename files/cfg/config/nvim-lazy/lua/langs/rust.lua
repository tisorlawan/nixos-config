vim.g.rustaceanvim = {
  tools = {},
  server = {
    default_settings = {
      ["rust-analyzer"] = {
        checkOnSave = true,
        ["check.command"] = "check",
        -- ["cargo.extraEnv"] = {
        --   ["RUSTFLAGS"] = "-C linker=clang -C link-arg=-fuse-ld=/run/current-system/sw/bin/mold",
        -- },
      },
    },
  },
  dap = {},
}

vim.keymap.set("n", "<C-y>", ":RustLsp flyCheck<cr>", { desc = "flycheck", silent = true })

return {
  "mrcjkb/rustaceanvim",
  version = "^5", -- Recommended
  lazy = false, -- This plugin is already lazy
  enabled = true,
}
