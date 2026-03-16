return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = ' '
    else
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    local icons = require('config.shared').icons
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

    return {
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
        lualine_b = { 'branch' },
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
  end,
}
