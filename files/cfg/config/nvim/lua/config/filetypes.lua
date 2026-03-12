vim.filetype.add {
  pattern = {
    ['%.env%.[%w_.-]+'] = 'sh',
  },
  extension = {
    lisp = 'lisp',
    cl = 'lisp',
    lsp = 'lisp',
    asd = 'lisp',
  },
  filename = {
    sbclrc = 'lisp',
    ['.sbclrc'] = 'lisp',
  },
}
