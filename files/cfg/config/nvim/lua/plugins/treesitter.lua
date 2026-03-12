return {
  'nvim-treesitter/nvim-treesitter',
  main = 'nvim-treesitter.configs',
  branch = 'master',
  build = ':TSUpdate',
  dependencies = {
    -- { 'yioneko/nvim-yati', event = { 'BufReadPost', 'BufNewFile' } },
    { 'windwp/nvim-ts-autotag' },
  },
  lazy = false,
  opts = {
    ensure_installed = {
      'bash',
      'clojure',
      'commonlisp',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'python',
      'vim',
      'vimdoc',
    },
    auto_install = true,
    highlight = {
      enable = true,
      disable = { 'lisp', 'commonlisp' },
      -- additional_vim_regex_highlighting = { 'ruby', 'elixir' },
    },
    indent = {
      enable = true,
      -- disable = { 'clojure', 'c', 'css', 'heex', 'javascript', 'json', 'lua', 'lisp', 'python', 'rust', 'scheme', 'toml', 'tsx', 'typescript', 'yaml' },
    },
    -- yati = {
    --   enable = true,
    --   disable = { 'rust', 'cpp' },
    --   default_lazy = true,
    --   default_fallback = 'auto',
    -- },
  },
}
