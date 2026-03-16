local map = vim.keymap.set
local augroup = vim.api.nvim_create_augroup('UserConfigFocus', { clear = true })

local state = {
  enabled = false,
  defaults = nil,
  global = nil,
  windows = {},
}

local function is_normal_window(win)
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end

  local config = vim.api.nvim_win_get_config(win)
  if config.relative ~= '' then
    return false
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local bo = vim.bo[buf]

  return bo.buftype == '' and bo.filetype ~= 'toggleterm'
end

local function apply_to_window(win)
  if type(win) ~= 'number' then
    return
  end

  if not is_normal_window(win) then
    return
  end

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].winbar = ' '

  local winhighlight = vim.wo[win].winhighlight
  if winhighlight == '' then
    vim.wo[win].winhighlight = table.concat({
      'NormalNC:Normal',
      'FoldColumn:Normal',
      'SignColumn:Normal',
      'LineNr:Normal',
      'CursorLineNr:Normal',
      'CursorLineFold:Normal',
      'CursorLineSign:Normal',
      'EndOfBuffer:Normal',
    }, ',')
  else
    local mappings = {
      'NormalNC:Normal',
      'FoldColumn:Normal',
      'SignColumn:Normal',
      'LineNr:Normal',
      'CursorLineNr:Normal',
      'CursorLineFold:Normal',
      'CursorLineSign:Normal',
      'EndOfBuffer:Normal',
    }

    for _, mapping in ipairs(mappings) do
      local name = mapping:match '^[^:]+'
      if not winhighlight:find(name .. ':', 1, true) then
        winhighlight = winhighlight .. ',' .. mapping
      end
    end

    vim.wo[win].winhighlight = winhighlight
  end
end

local function save_window_state(win, values)
  state.windows[win] = values
    or {
      number = vim.wo[win].number,
      relativenumber = vim.wo[win].relativenumber,
      winbar = vim.wo[win].winbar,
      winhighlight = vim.wo[win].winhighlight,
    }
end

local function restore_window(win)
  local previous = state.windows[win]
  state.windows[win] = nil

  if not previous or not vim.api.nvim_win_is_valid(win) then
    return
  end

  vim.wo[win].number = previous.number
  vim.wo[win].relativenumber = previous.relativenumber
  vim.wo[win].winbar = previous.winbar
  vim.wo[win].winhighlight = previous.winhighlight
end

local function apply_to_all_windows()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if is_normal_window(win) then
      save_window_state(win)
      apply_to_window(win)
    end
  end
end

local function restore_all_windows()
  for win, _ in pairs(state.windows) do
    restore_window(win)
  end
end

local function toggle()
  state.enabled = not state.enabled

  if state.enabled then
    state.defaults = {
      number = vim.o.number,
      relativenumber = vim.o.relativenumber,
    }
    state.global = {
      cmdheight = vim.o.cmdheight,
      fillchars = vim.opt.fillchars:get(),
      laststatus = vim.o.laststatus,
    }
    state.windows = {}
    vim.o.cmdheight = 0
    vim.opt.fillchars = state.global.fillchars
    vim.opt.fillchars:append { eob = ' ' }
    vim.o.laststatus = 0
    apply_to_all_windows()
  else
    restore_all_windows()
    if state.global then
      vim.o.cmdheight = state.global.cmdheight
      vim.opt.fillchars = state.global.fillchars
      vim.o.laststatus = state.global.laststatus
    end
    state.defaults = nil
    state.global = nil
  end
end

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
  group = augroup,
  callback = function()
    if not state.enabled then
      return
    end

    local win = vim.api.nvim_get_current_win()
    if not state.windows[win] and is_normal_window(win) then
      save_window_state(win, state.defaults)
    end

    apply_to_window(win)
  end,
})

vim.api.nvim_create_autocmd('WinClosed', {
  group = augroup,
  callback = function(args)
    state.windows[tonumber(args.match)] = nil
  end,
})

map('n', '<leader>zz', toggle, { desc = 'Toggle focus mode' })

return {
  toggle = toggle,
}
