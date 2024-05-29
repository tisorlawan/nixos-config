return {
  "folke/which-key.nvim",
  event = "VimEnter",
  config = function()
    require("which-key").setup()
    require("which-key").register({
      ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
      ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
      ["<leader>f"] = { name = "[F]zf search", _ = "which_key_ignore" },
      ["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
      ["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
      ["<leader>t"] = { name = "[T]oggle", _ = "which_key_ignore" },
      ["<leader>l"] = { name = "Lazy|Lsp", _ = "which_key_ignore" },
      ["<leader>z"] = { name = "Fold", _ = "which_key_ignore" },
    })

    require("which-key").register({
      ["<leader>h"] = { "Git [H]unk" },
    }, { mode = "v" })
  end,
}
