return {
  "tisorlawan/vim-asterisk",
  config = function()
    vim.cmd([[
      nmap *   <Plug>(asterisk-z*)
      map #   <Plug>(asterisk-z#)
      map g*  <Plug>(asterisk-gz*)
      map g#  <Plug>(asterisk-gz#)
      map z*  <Plug>(asterisk-*)
      map gz* <Plug>(asterisk-z*)
      map z#  <Plug>(asterisk-#)
      map gz# <Plug>(asterisk-z#)
      let g:asterisk#keeppos = 1
    ]])
  end,
}
