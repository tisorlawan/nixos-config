-- virtual, bacground, foreground
vim.cmd([[ let g:Hexokinase_highlighters = ['virtual'] ]])
return {
  "rrethy/vim-hexokinase",
  build = "make hexokinase",
}
