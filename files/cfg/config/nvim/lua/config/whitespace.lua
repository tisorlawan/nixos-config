local M = {
  enabled_by_ft = {
    lua = true,
    lisp = true,
  },
}

function M.trim(bufnr)
  local ok, trailspace = pcall(require, 'mini.trailspace')
  if not ok then
    return false
  end

  local target = bufnr or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_call(target, function()
    local view = vim.fn.winsaveview()
    trailspace.trim()
    trailspace.trim_last_lines()
    vim.fn.winrestview(view)
  end)

  return true
end

function M.set_enabled(filetype, enabled)
  if filetype == '' then
    vim.notify('No filetype for current buffer', vim.log.levels.WARN)
    return
  end

  M.enabled_by_ft[filetype] = enabled or nil
  vim.notify(string.format('Trailing whitespace trim on save %s for %s', enabled and 'enabled' or 'disabled', filetype), vim.log.levels.INFO)
end

return M
