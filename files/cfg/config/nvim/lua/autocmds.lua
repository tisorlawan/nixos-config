vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "fzf" },
  callback = function(event)
    -- remove small delay in <C-c>
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("t", "<C-c>", "<C-c>", { buffer = event.buf, silent = true })
  end,
})
