return {
  'eraserhd/parinfer-rust',
  enabled = require('config.shared').get_used_filetypes().enabled.lisp == true and vim.fn.executable 'cargo' == 1,
  ft = { 'carp', 'clojure', 'dune', 'fennel', 'hy', 'janet', 'lisp', 'racket', 'scheme', 'wast', 'yuck' },
  build = 'cargo build --release',
  init = function()
    vim.g.parinfer_mode = 'smart'
  end,
}
