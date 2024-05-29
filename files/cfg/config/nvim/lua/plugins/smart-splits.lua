return {
  "mrjones2014/smart-splits.nvim",
  version = "v1.3.0",
  config = function()
    local s = require("smart-splits")

    vim.keymap.set("n", "<C-left>", s.resize_left)
    vim.keymap.set("n", "<C-down>", s.resize_down)
    vim.keymap.set("n", "<C-up>", s.resize_up)
    vim.keymap.set("n", "<C-right>", s.resize_right)
    -- moving between splits
    vim.keymap.set("n", "<C-h>", s.move_cursor_left)
    vim.keymap.set("n", "<C-j>", s.move_cursor_down)
    vim.keymap.set("n", "<C-k>", s.move_cursor_up)
    vim.keymap.set("n", "<C-l>", s.move_cursor_right)
    -- swapping buffers between windows
    vim.keymap.set("n", "<leader><leader>h", s.swap_buf_left, { desc = "swap left" })
    vim.keymap.set("n", "<leader><leader>j", s.swap_buf_down, { desc = "swap down" })
    vim.keymap.set("n", "<leader><leader>k", s.swap_buf_up, { desc = "swap top" })
    vim.keymap.set("n", "<leader><leader>l", s.swap_buf_right, { desc = "swap right" })

    s.setup({
      ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
      ignored_buftypes = { "nofile" },
    })
  end,
}
