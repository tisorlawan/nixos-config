local M = {}

local modules = {
  'config.bootstrap',
  'config.shared',
  'config.options',
  'config.filetypes',
  'config.whitespace',
  'config.colorcolumn',
  'config.keymaps',
  'config.grep',
  'config.harpoon',
  'config.terminal',
  'config.sbcl',
  'config.commands',
  'config.autocmds',
  'config.lsp',
}

local function has_enabled_filetype(target)
  local used = require('config.shared').get_used_filetypes().enabled
  return used[target] == true
end

local function has_enabled_lsp_filetype()
  local used = require('config.shared').get_used_filetypes()

  for _, filetype in ipairs(used.used_ft) do
    local config = used.config[filetype]
    if config and config.servers and #config.servers > 0 then
      return true
    end
  end

  return false
end

function M.setup()
  for _, module in ipairs(modules) do
    package.loaded[module] = nil
  end

  require 'config.bootstrap'
  require 'config.options'
  require 'config.filetypes'
  require 'config.keymaps'
  require('config.grep').setup()
  require('config.harpoon').setup()
  require('config.terminal').setup()

  if has_enabled_filetype 'lisp' then
    require('config.sbcl').setup()
  end

  require('config.commands').setup()
  require('config.autocmds').setup()

  if has_enabled_lsp_filetype() then
    require('config.lsp').setup()
  end
end

return M
