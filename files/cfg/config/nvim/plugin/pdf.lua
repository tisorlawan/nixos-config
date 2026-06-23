-- Open PDFs in sioyek instead of loading their binary contents into a buffer.
-- BufReadCmd takes over reading the file, so Neovim never shows the binary
-- garbage; this covers any path that :edit-s a *.pdf (file pickers, neo-tree,
-- gf, :edit).
vim.api.nvim_create_autocmd('BufReadCmd', {
  group = vim.api.nvim_create_augroup('open-pdf-external', { clear = true }),
  pattern = '*.pdf',
  callback = function(args)
    local path = vim.api.nvim_buf_get_name(args.buf)
    vim.fn.jobstart({ 'sioyek', path }, { detach = true })

    -- Drop the placeholder buffer; Neovim swaps in the alternate buffer
    -- (or a new empty one) for any window that was showing it.
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) then
        vim.api.nvim_buf_delete(args.buf, { force = true })
      end
    end)
  end,
})
