local M = {} -- my "table" stdlib

--- Merge all the given tables into a single one and return it.
function M.tbl_merge_all(...)
  local ret = {}
  for _, tbl in ipairs({ ... }) do
    for k, v in pairs(tbl) do
      ret[k] = v
    end
  end
  return ret
end

local is_list = function(t)
  if type(t) ~= "table" then
    return false
  end
  -- a list has list indices, an object does not
  return ipairs(t)(t, 0) and true or false
end

--- Flatten the given list of (item or (list of (item or ...)) to a list of item.
-- (nested lists are supported)
function M.tbl_flatten_list(list)
  local flattened_list = {}
  for _, item in ipairs(list) do
    if is_list(item) then
      for _, sub_item in ipairs(M.tbl_flatten_list(item)) do
        table.insert(flattened_list, sub_item)
      end
    else
      table.insert(flattened_list, item)
    end
  end
  return flattened_list
end

function M.keybind(mods, keys, action)
  local keys = (type(keys) == "table") and keys or { keys }
  local mods = mods
  local binds = {}
  for _, key in ipairs(keys) do
    table.insert(binds, { mods = mods, key = key, action = action })
  end
  return binds
end

M.mods = setmetatable({
  _SHORT_MOD_MAP = {
    _ = "NONE",
    C = "CTRL",
    S = "SHIFT",
    A = "ALT",
    D = "SUPER", -- D for Desktop (Win/Cmd/Super)
    L = "LEADER", -- D for Desktop (Win/Cmd/Super)
  },
}, {
  -- Dynamically transform key access of 'CSA' to 'CTRL|SHIFT|ALT'
  __index = function(self, key)
    local resolved_mods = self._SHORT_MOD_MAP[key:sub(1, 1)]
    for i = 2, #key do
      local char = key:sub(i, i)
      resolved_mods = resolved_mods .. "|" .. self._SHORT_MOD_MAP[char]
    end
    return resolved_mods
  end,
})

return M
