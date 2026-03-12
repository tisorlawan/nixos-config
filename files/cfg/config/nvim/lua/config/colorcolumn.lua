local M = {}

M.rules = {
  gitcommit = { enable = false, limits = { 50, 72 } },
  markdown = { enable = false, limits = { 80 } },
  python = { enable = false, limits = { 88 } },
}

function M.parse(input)
  local columns = {}

  for value in input:gmatch '[^,%s]+' do
    local num = tonumber(value)
    if not num or num < 1 then
      return nil
    end

    table.insert(columns, tostring(math.floor(num)))
  end

  if #columns == 0 then
    return nil
  end

  return table.concat(columns, ',')
end

function M.default_for(filetype)
  local rule = M.rules[filetype]
  if not rule or not rule.enable or not rule.limits or #rule.limits == 0 then
    return ''
  end

  return table.concat(vim.tbl_map(tostring, rule.limits), ',')
end

function M.apply()
  vim.wo.colorcolumn = M.default_for(vim.bo.filetype)
end

return M
