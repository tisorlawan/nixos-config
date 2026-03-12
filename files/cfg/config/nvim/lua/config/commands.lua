local M = {}

local colorcolumn = require 'config.colorcolumn'
local whitespace = require 'config.whitespace'

local function get_init_path()
  local myvimrc = vim.env.MYVIMRC or (vim.fn.stdpath 'config' .. '/init.lua')
  return vim.fn.fnamemodify(myvimrc, ':p')
end

local function has_modified_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified then
      return true
    end
  end

  return false
end

local function pick_restart_target(init_path)
  local current = vim.api.nvim_buf_get_name(0)
  if current ~= '' then
    local current_path = vim.fn.fnamemodify(current, ':p')
    if current_path ~= init_path then
      return current_path
    end
  end

  local from_ec = vim.g.ec_return_file
  if type(from_ec) == 'string' and from_ec ~= '' and vim.fn.filereadable(from_ec) == 1 then
    return from_ec
  end

  local current_buf = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current_buf and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= '' then
        local path = vim.fn.fnamemodify(name, ':p')
        if path ~= init_path and vim.fn.filereadable(path) == 1 then
          return path
        end
      end
    end
  end

  return ''
end

function M.setup()
  vim.api.nvim_create_user_command('TrimWhitespace', function(opts)
    local bufnr = opts.args ~= '' and tonumber(opts.args) or vim.api.nvim_get_current_buf()
    if bufnr == nil or not vim.api.nvim_buf_is_valid(bufnr) then
      vim.notify('TrimWhitespace: invalid buffer', vim.log.levels.ERROR)
      return
    end

    whitespace.trim(bufnr)
  end, { desc = 'Trim trailing whitespace in buffer', force = true, nargs = '?' })

  vim.api.nvim_create_user_command('TrimWhitespaceEnableOnSave', function()
    whitespace.set_enabled(vim.bo.filetype, true)
  end, { desc = 'Enable trailing whitespace trim on save for filetype', force = true })

  vim.api.nvim_create_user_command('TrimWhitespaceDisableOnSave', function()
    whitespace.set_enabled(vim.bo.filetype, false)
  end, { desc = 'Disable trailing whitespace trim on save for filetype', force = true })

  vim.api.nvim_create_user_command('TrimWhitespaceToggleOnSave', function()
    local filetype = vim.bo.filetype
    whitespace.set_enabled(filetype, not whitespace.enabled_by_ft[filetype])
  end, { desc = 'Toggle trailing whitespace trim on save for filetype', force = true })

  vim.api.nvim_create_user_command('ToggleParinfer', function()
    if vim.fn.exists ':ParinferOn' == 0 or vim.fn.exists ':ParinferOff' == 0 then
      vim.notify('Parinfer is not available in this buffer', vim.log.levels.WARN)
      return
    end

    local enabled = vim.g.parinfer_enabled ~= 0
    vim.cmd(enabled and 'ParinferOff' or 'ParinferOn')
    vim.notify(string.format('Parinfer %s', enabled and 'disabled' or 'enabled'), vim.log.levels.INFO)
  end, { desc = 'Toggle parinfer', force = true })

  vim.api.nvim_create_user_command('ColorColumnToggle', function(cmd_opts)
    if vim.wo.colorcolumn ~= '' then
      vim.wo.colorcolumn = ''
      return
    end

    local parsed = cmd_opts.args ~= '' and colorcolumn.parse(cmd_opts.args) or nil
    local default = colorcolumn.default_for(vim.bo.filetype)
    if default == '' then
      default = '80'
    end

    vim.wo.colorcolumn = parsed or default
  end, { desc = 'Toggle colorcolumn in current window', force = true, nargs = '?' })

  vim.api.nvim_create_user_command('ColorColumnSet', function(cmd_opts)
    local parsed = colorcolumn.parse(cmd_opts.args)
    if not parsed then
      vim.notify('ColorColumnSet: expected positive integer columns, e.g. 80 or 80,100', vim.log.levels.ERROR)
      return
    end

    vim.wo.colorcolumn = parsed
  end, { desc = 'Set colorcolumn in current window', force = true, nargs = 1 })

  vim.api.nvim_create_user_command('ColorColumnClear', function()
    vim.wo.colorcolumn = ''
  end, { desc = 'Clear colorcolumn in current window', force = true })

  vim.api.nvim_create_user_command('Ec', function()
    local init_path = get_init_path()
    local current = vim.api.nvim_buf_get_name(0)

    if current ~= '' then
      local current_path = vim.fn.fnamemodify(current, ':p')
      if current_path ~= init_path and vim.bo[0].buftype == '' then
        vim.g.ec_return_file = current_path
      end
    end

    vim.cmd('edit ' .. vim.fn.fnameescape(init_path))
    vim.bo[0].buflisted = false
  end, { force = true })

  vim.api.nvim_create_user_command('Rr', function()
    if has_modified_buffers() then
      vim.notify('Save changes first before :rr', vim.log.levels.WARN)
      return
    end

    local init_path = get_init_path()
    local target = pick_restart_target(init_path)

    vim.cmd('source ' .. vim.fn.fnameescape(init_path))

    if target ~= '' and vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p') ~= target then
      vim.cmd('edit ' .. vim.fn.fnameescape(target))
    end

    vim.cmd.redrawstatus()
    vim.notify('Config reloaded' .. (target ~= '' and (' -> ' .. target) or ''), vim.log.levels.INFO)
  end, { force = true })

  vim.cmd 'silent! cunabbrev ec'
  vim.cmd 'silent! cunabbrev rr'
  vim.cmd [[cnoreabbrev <expr> ec getcmdtype() == ':' && getcmdline() == 'ec' ? 'Ec' : 'ec']]
  vim.cmd [[cnoreabbrev <expr> rr getcmdtype() == ':' && getcmdline() == 'rr' ? 'Rr' : 'rr']]
end

return M
