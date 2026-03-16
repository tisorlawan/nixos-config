vim.pack.add { 'https://github.com/nvim-treesitter/nvim-treesitter' }

local parser_aliases = {
  javascriptreact = 'tsx',
  lisp = 'commonlisp',
  sh = 'bash',
  typescriptreact = 'tsx',
}

local common_parsers = {
  'lua',
  'markdown',
  'query',
  'vim',
  'vimdoc',
}

local parsers = vim.deepcopy(common_parsers)
local seen = {}

for _, parser in ipairs(parsers) do
  seen[parser] = true
end

for _, filetype in ipairs(require('shared').get_used_filetypes().used_ft) do
  local parser = parser_aliases[filetype] or filetype

  if not seen[parser] then
    table.insert(parsers, parser)
    seen[parser] = true
  end
end

require('nvim-treesitter').install(parsers)
