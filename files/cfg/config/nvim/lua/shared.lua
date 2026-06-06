local M = {}

M.icons = {
  diagnostics = {
    Error = ' ',
    Warn = ' ',
    Hint = ' ',
    Info = ' ',
  },
}

local filetype_config = {
  lisp = {},
  -- c = { formatters = { 'clang_format' }, servers = { 'clangd' } },
  c = { formatters = {}, servers = { 'clangd' } },
  go = { formatters = { 'gofumpt', 'goimports', 'golines' }, servers = { 'gopls' } },
  html = { formatters = { 'oxfmt' }, servers = { 'html' } },
  javascript = { formatters = { 'oxfmt' } },
  json = { formatters = { 'oxfmt' } },
  lua = { formatters = { 'stylua' }, servers = { 'lua_ls' } },
  markdown = { formatters = { 'oxfmt' }, servers = { 'marksman' } },
  nix = { formatters = { 'nixpkgs_fmt' }, servers = { 'nil_ls' } },
  php = { formatters = { 'php_cs_fixer' }, servers = { 'phpactor', 'laravel_ls', 'html' } },
  python = { formatters = { 'ruff_format', 'ruff_organize_imports' }, servers = { 'pyright', 'ruff' } },
  rust = { formatters = { 'rustfmt' }, servers = { 'rust_analyzer' } },
  sh = { formatters = { 'shfmt' }, servers = { 'bashls' } },
  typescript = { formatters = { 'oxfmt' }, servers = { 'ts_ls', 'eslint' } },
  typescriptreact = { formatters = { 'oxfmt' }, servers = { 'ts_ls', 'eslint' } },
  zig = { formatters = { 'zigfmt' }, servers = { 'zls' } },
}

local used_filetypes_cache

function M.get_used_filetypes()
  if used_filetypes_cache then
    return used_filetypes_cache
  end

  local filetypes = {}
  local file_path = vim.fn.stdpath 'config' .. '/ft'
  local handle = io.open(file_path, 'r')

  if handle then
    for line in handle:lines() do
      local trimmed = line:gsub('^%s*(.-)%s*$', '%1')
      if trimmed ~= '' and trimmed:sub(1, 1) ~= '#' and trimmed:sub(1, 4) ~= 'vim:' then
        table.insert(filetypes, trimmed)
      end
    end

    handle:close()
  end

  local formatters_by_ft = {}
  local enabled = {}

  for _, filetype in ipairs(filetypes) do
    enabled[filetype] = true
    local config = filetype_config[filetype]
    if config and config.formatters then
      formatters_by_ft[filetype] = config.formatters
    end
  end

  used_filetypes_cache = {
    used_ft = filetypes,
    enabled = enabled,
    config = filetype_config,
    formatters_by_ft = formatters_by_ft,
  }

  return used_filetypes_cache
end

return M
