return {
  "tisorlawan/vim-grepper",
  config = function()
    vim.cmd([[
        let g:grepper = {
        \ 'tools': ['rg'],
        \ 'pt': {
        \   'grepprg':    'pt --nocolor --nogroup',
        \   'grepformat': '%f:%l:%m',
        \   'escape':     '\+*^$()[]',
        \ }}

        nmap gs  <plug>(GrepperOperator)
        xmap gs  <plug>(GrepperOperator)
        nnoremap gss :Grepper -tool rg<cr>
        ]])
  end,
}
