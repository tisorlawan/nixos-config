if require('shared').get_used_filetypes().enabled.markdown ~= true then
  return
end

vim.pack.add {
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
}
require('render-markdown').setup {
  enabled = false,
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function(event)
    vim.keymap.set('n', '<leader>uu', '<cmd>RenderMarkdown toggle<cr>', {
      buf = event.buf,
      desc = 'Toggle Markdown Highlight',
    })
  end,
})
