return {
  {
    "https://git.sr.ht/~swaits/zellij-nav.nvim",
    lazy = true,
    event = "VeryLazy",
    enabled = false,
    keys = {
      { "<c-h>", "<cmd>ZellijNavigateLeftTab<cr>", { silent = true, desc = "navigate left or tab" } },
      { "<c-j>", "<cmd>ZellijNavigateDown<cr>", { silent = true, desc = "navigate down" } },
      { "<c-k>", "<cmd>ZellijNavigateUp<cr>", { silent = true, desc = "navigate up" } },
      { "<c-l>", "<cmd>ZellijNavigateRightTab<cr>", { silent = true, desc = "navigate right or tab" } },
    },
    opts = {},
  },
  {
    "mrjones2014/smart-splits.nvim",
    enabled = true,
    lazy = true,
  -- stylua: ignore
  keys = {
    { "<C-h>", function() require("smart-splits").move_cursor_left() end, { silent = true }, },
    { "<C-j>", function() require("smart-splits").move_cursor_down() end, { silent = true }, },
    { "<C-k>", function() require("smart-splits").move_cursor_up() end, { silent = true }, },
    { "<C-l>", function() require("smart-splits").move_cursor_right() end, { silent = true }, },
    { "<C-left>", function() require("smart-splits").resize_left() end, { silent = true }, },
    { "<C-right>", function() require("smart-splits").resize_right() end, { silent = true }, },
    { "<C-up>", function() require("smart-splits").resize_up() end, { silent = true }, },
    { "<C-down>", function() require("smart-splits").resize_down() end, { silent = true }, },
    { "<leader>oh", function() require("smart-splits").swap_buf_left() end, { silent = true }, desc = "Swap Left", },
    { "<leader>oj", function() require("smart-splits").swap_buf_down() end, { silent = true }, desc = "Swap Down", },
    { "<leader>ok", function() require("smart-splits").swap_buf_up() end, { silent = true }, desc = "Swap Up", },
    { "<leader>ol", function() require("smart-splits").swap_buf_right() end, { silent = true }, desc = "Swap Right", },
  },
    config = function()
      local s = require("smart-splits")

      s.setup({
        ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
        ignored_buftypes = { "nofile" },
      })
    end,
  },
}
