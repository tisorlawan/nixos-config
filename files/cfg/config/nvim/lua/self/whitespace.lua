local map = vim.keymap.set
local augroup = vim.api.nvim_create_augroup('UserConfigWhitespace', { clear = true })

local enabled_by_ft = {
  lua = true,
  lisp = true,
}

local function trim_trailing_whitespace(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local changed = false

  for i, line in ipairs(lines) do
    local trimmed = line:gsub('%s+$', '')
    if trimmed ~= line then
      lines[i] = trimmed
      changed = true
    end
  end

  local last_nonblank = 0
  for i = #lines, 1, -1 do
    if lines[i]:find '%S' then
      last_nonblank = i
      break
    end
  end

  local trimmed_line_count = math.max(last_nonblank, 1)
  if trimmed_line_count ~= #lines then
    lines = vim.list_slice(lines, 1, trimmed_line_count)
    changed = true
  end

  if changed then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  end

  return changed
end

local function trima(bufnr)
  local target = bufnr or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_call(target, function()
    local view = vim.fn.winsaveview()
    trim_trailing_whitespace(target)
    vim.fn.winrestview(view)
  end)

  return true
end

local function set_enabled(filetype, enabled)
  if filetype == '' then
    vim.notify('No filetype for current buffer', vim.log.levels.WARN)
    return
  end

  enabled_by_ft[filetype] = enabled or nil
  vim.notify(string.format('Trailing whitespace trim on save %s for %s', enabled and 'enabled' or 'disabled', filetype), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('TrimWhitespace', function(opts)
  local bufnr = opts.args ~= '' and tonumber(opts.args) or vim.api.nvim_get_current_buf()
  if bufnr == nil or not vim.api.nvim_buf_is_valid(bufnr) then
    vim.notify('TrimWhitespace: invalid buffer', vim.log.levels.ERROR)
    return
  end

  trima(bufnr)
end, { desc = 'Trim trailing whitespace in buffer', force = true, nargs = '?' })

vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup,
  callback = function(event)
    if vim.bo[event.buf].buftype ~= '' or not vim.bo[event.buf].modifiable then
      return
    end

    local filetype = vim.bo[event.buf].filetype
    if enabled_by_ft[filetype] then
      trima(event.buf)
    end
  end,
})

vim.api.nvim_create_user_command('TrimWhitespaceEnableOnSave', function()
  set_enabled(vim.bo.filetype, true)
end, { desc = 'Enable trailing whitespace trim on save for filetype', force = true })

vim.api.nvim_create_user_command('TrimWhitespaceDisableOnSave', function()
  set_enabled(vim.bo.filetype, false)
end, { desc = 'Disable trailing whitespace trim on save for filetype', force = true })

vim.api.nvim_create_user_command('TrimWhitespaceToggleOnSave', function()
  local filetype = vim.bo.filetype
  set_enabled(filetype, not enabled_by_ft[filetype])
end, { desc = 'Toggle trailing whitespace trim on save for filetype', force = true })

map('n', '<leader>uws', '<cmd>TrimWhitespaceToggleOnSave<cr>', { desc = 'Toggle trim on save' })
