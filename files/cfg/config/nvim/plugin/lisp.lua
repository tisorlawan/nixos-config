-- Mostly inspired by https://susam.net/lisp-in-vim.html#comparison-of-slimv-and-vlime
if require('shared').get_used_filetypes().enabled.lisp ~= true then
  return
end

vim.g.slimv_keybindings = 1
vim.g.slimv_repl_split = 4
vim.g.slimv_unmap_cr = 1
vim.g.slimv_unmap_tab = 1
vim.g.slimv_unmap_space = 1
vim.g.paredit_mode = 0
vim.g.paredit_electric_return = 0
vim.g.parinfer_mode = 'smart'

do
  vim.g.parinfer_dylib_path = vim.fs.joinpath(vim.fn.stdpath 'data', 'site', 'pack', 'core', 'opt', 'parinfer-rust', 'target', 'release', 'libparinfer_rust.so')
end

vim.pack.add {
  'https://github.com/kovisoft/slimv.git',
  {
    src = 'https://github.com/eraserhd/parinfer-rust.git',
    name = 'parinfer-rust',
  },
}
