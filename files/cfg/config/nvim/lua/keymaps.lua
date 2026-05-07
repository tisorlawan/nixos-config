local map = vim.keymap.set

local function close_special_windows()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local info = vim.fn.getwininfo(win)[1]
      vim.api.nvim_win_call(win, function()
        local buf = vim.api.nvim_get_current_buf()
        local buftype = vim.bo[buf].buftype
        local filetype = vim.bo[buf].filetype

        if info and info.loclist == 1 then
          vim.cmd.lclose()
        elseif buftype == 'quickfix' then
          vim.cmd.cclose()
        elseif buftype == 'help' or filetype == 'trouble' then
          vim.cmd.bdelete()
        elseif filetype == 'toggleterm' or filetype == 'neo-tree-popup' or filetype == 'Outline' then
          vim.cmd.close()
        end
      end)
    end
  end

  vim.cmd.cclose()
  vim.cmd.lclose()
end

local function resize_window(direction, amount)
  local current = vim.api.nvim_get_current_win()
  local left = vim.fn.win_getid(vim.fn.winnr 'h')
  local right = vim.fn.win_getid(vim.fn.winnr 'l')
  local up = vim.fn.win_getid(vim.fn.winnr 'k')
  local down = vim.fn.win_getid(vim.fn.winnr 'j')

  if direction == 'left' then
    if left ~= current then
      vim.fn.win_move_separator(left, -amount)
    else
      vim.fn.win_move_separator(current, -amount)
    end
  elseif direction == 'right' then
    if right ~= current then
      vim.fn.win_move_separator(current, amount)
    else
      vim.fn.win_move_separator(left, amount)
    end
  elseif direction == 'up' then
    if up ~= current then
      vim.fn.win_move_statusline(up, -amount)
    else
      vim.fn.win_move_statusline(current, -amount)
    end
  elseif direction == 'down' then
    if down ~= current then
      vim.fn.win_move_statusline(current, amount)
    else
      vim.fn.win_move_statusline(up, amount)
    end
  end
end

map('n', '<leader>w', '<cmd>update<CR>', { desc = 'Save file' })

map('i', '<C-a>', '<C-o>^', { desc = 'Beginning of line' })
map('i', '<C-e>', '<End>', { desc = 'End of line' })
map('i', '<C-h>', '<Left>', { desc = 'Move left' })
map('i', '<C-j>', '<Down>', { desc = 'Move down' })
map('i', '<C-k>', '<Up>', { desc = 'Move up' })
map('i', '<C-l>', '<Right>', { desc = 'Move right' })

map('n', '<C-h>', '<C-w>h', { desc = 'Move left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Move down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Move up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Move right' })

map({ 'n', 't' }, '<C-Left>', function()
  resize_window('left', 2)
end, { desc = 'Resize split left' })
map({ 'n', 't' }, '<C-Right>', function()
  resize_window('right', 2)
end, { desc = 'Resize split right' })
map({ 'n', 't' }, '<C-Up>', function()
  resize_window('up', 2)
end, { desc = 'Resize split up' })
map({ 'n', 't' }, '<C-Down>', function()
  resize_window('down', 2)
end, { desc = 'Resize split down' })

map('n', '<leader><Tab>', '<C-^>', { desc = 'Alternate buffer' })
map('n', "'", '`', { desc = 'Go to mark exact' })
map('n', '`', "'", { desc = 'Go to mark line' })

map('n', 'cq', close_special_windows, { desc = 'Close diagnostics', silent = true })
map('n', 'cn', '<cmd>cnext<CR>', { desc = 'Quickfix next' })
map('n', 'cp', '<cmd>cprev<CR>', { desc = 'Quickfix prev' })
map('n', 'co', '<cmd>copen<CR>', { desc = 'Quickfix open' })

map('n', '<leader>yp', function()
  local path = vim.fn.expand '%:.'
  vim.fn.setreg('+', path)
  print('Copied: ' .. path)
end, { desc = 'Copy relative path' })

map('n', '<leader>yP', function()
  local path = vim.fn.expand '%:p'
  vim.fn.setreg('+', path)
  print('Copied: ' .. path)
end, { desc = 'Copy absolute path' })

map('n', '<leader>un', function()
  local enabled = not (vim.wo.number and vim.wo.relativenumber)

  vim.wo.number = enabled
  vim.wo.relativenumber = enabled
end, { desc = 'Toggle number + relativenumber' })

map('n', '<leader>us', function()
  local enabled = vim.wo.signcolumn == 'no'

  vim.wo.signcolumn = enabled and 'yes' or 'no'
end, { desc = 'Toggle signcolumn' })

map('n', '<leader>ul', function()
  vim.wo.cursorline = not vim.wo.cursorline
end, { desc = 'Toggle cursorline' })

map('n', '<leader>xf', function()
  local directory = vim.fn.expand '%:.:h'
  if directory == '' or directory == '.' then
    directory = ''
  else
    directory = directory .. '/'
  end

  local filepath = vim.fn.input('New file: ', directory, 'file')
  if filepath ~= '' and filepath ~= directory then
    vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
  end
end, { desc = 'New file in current dir' })

map('n', '<leader>xc', function()
  local file = vim.fn.expand '%:p'
  if file == '' or vim.fn.filereadable(file) ~= 1 then
    return
  end

  vim.fn.system('chmod +x ' .. vim.fn.shellescape(file))
  print('Made executable: ' .. file)
end, { desc = 'Chmod +x current file' })

map('n', '<leader>R', function()
  local session = vim.fn.stdpath 'state' .. '/restart_session.vim'
  vim.cmd('mksession! ' .. vim.fn.fnameescape(session))
  vim.cmd('restart source ' .. vim.fn.fnameescape(session))
end, { desc = 'Restart Neovim' })

local semicolon_filetypes = {
  'c',
  'cpp',
  'rust',
  'java',
  'javascript',
  'typescript',
  'typescriptreact',
  'css',
  'php',
  'go',
  'zig',
}

local semicolon_enabled = {}
for _, filetype in ipairs(semicolon_filetypes) do
  semicolon_enabled[filetype] = true
end

map('i', '<C-d>', function()
  if not semicolon_enabled[vim.bo.filetype] then
    return ''
  end

  local line = vim.fn.getline '.'
  if line:sub(-1) ~= ';' then
    return '<End>;'
  end

  return '<End>'
end, { desc = 'Append semicolon', expr = true })
