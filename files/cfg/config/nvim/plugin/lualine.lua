vim.pack.add {
  'https://github.com/linrongbin16/lsp-progress.nvim',
  'https://github.com/nvim-lualine/lualine.nvim',
}

vim.g.lualine_laststatus = vim.o.laststatus
if vim.fn.argc(-1) > 0 then
  vim.o.statusline = ' '
else
  vim.o.laststatus = 0
end

local icons = require('shared').icons
local lualine_require = require 'lualine_require'

lualine_require.require = require
vim.o.laststatus = vim.g.lualine_laststatus

local function file_path()
  local path = vim.fn.expand '%:p'
  local modified = vim.bo.modified and ' [+]' or ''
  local readonly = vim.bo.readonly and ' [RO]' or ''

  if path == '' then
    return '[No Name]' .. modified .. readonly
  end

  local display = vim.fn.fnamemodify(path, ':.')
  if display == path or display:match '^%.%.' then
    display = vim.fn.fnamemodify(path, ':~')
  end

  local parts = vim.split(display, '/')
  if #parts > 3 and #display >= 50 then
    display = parts[1] .. '/…/' .. parts[#parts]
  end

  return display .. modified .. readonly
end

require('lsp-progress').setup {
  format = function(client_messages)
    if #vim.lsp.get_clients { bufnr = 0 } == 0 then
      return ''
    end
    if #client_messages > 0 then
      return ' ' .. table.concat(client_messages, ' ')
    end
    return '󰄬'
  end,
  client_format = function(_, spinner, series_messages)
    if #series_messages > 0 then
      return spinner
    end
  end,
}

local group = vim.api.nvim_create_augroup('UserLspProgressStatus', { clear = true })
vim.api.nvim_create_autocmd('User', {
  group = group,
  pattern = 'LspProgressStatusUpdated',
  callback = require('lualine').refresh,
})

require('lualine').setup {
  options = {
    theme = 'auto',
    globalstatus = vim.o.laststatus == 3,
    disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'ministarter', 'snacks_dashboard' } },
    section_separators = '',
    component_separators = '',
  },
  sections = {
    lualine_a = {
      {
        'mode',
        fmt = function(str)
          return str:sub(1, 1)
        end,
      },
    },
    -- lualine_b = { 'branch' },
    lualine_b = {},
    lualine_c = {
      file_path,
      {
        'diagnostics',
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
      },
    },
    lualine_x = {
      function()
        return require('lsp-progress').progress()
      end,
      'diff',
    },
    lualine_y = {
      { 'searchcount', maxcount = 999, timeout = 500 },
      { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
      { 'location', padding = { left = 0, right = 1 } },
    },
    lualine_z = {
      function()
        return ' ' .. os.date '%R'
      end,
    },
  },
  inactive_sections = {
    lualine_c = { file_path },
  },
  extensions = { 'lazy' },
}
