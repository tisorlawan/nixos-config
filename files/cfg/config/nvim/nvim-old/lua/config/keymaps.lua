local map = vim.keymap.set

local terminal = require 'config.terminal'
local sbcl = require 'config.sbcl'

local function switch_away_from_current_buffer()
  local current = vim.api.nvim_get_current_buf()
  local alternate = vim.fn.bufnr '#'

  if alternate ~= -1 and alternate ~= current and vim.fn.buflisted(alternate) == 1 then
    vim.cmd.buffer(alternate)
  else
    vim.cmd.bnext()
  end

  if vim.api.nvim_get_current_buf() == current then
    vim.cmd.enew()
  end

  return current
end

local function hide_buffer()
  switch_away_from_current_buffer()
end

local function delete_buffer()
  local current = vim.api.nvim_get_current_buf()
  if vim.bo[current].modified then
    print 'Buffer has unsaved changes.'
    return
  end

  switch_away_from_current_buffer()
  pcall(vim.cmd, 'bwipeout ' .. current)
end

local zen_state = {
  active = false,
  saved = {},
}

local function toggle_zen_mode()
  if zen_state.active then
    vim.o.laststatus = zen_state.saved.laststatus
    vim.o.showtabline = zen_state.saved.showtabline
    vim.o.cmdheight = zen_state.saved.cmdheight
    vim.wo.number = zen_state.saved.number
    vim.wo.relativenumber = zen_state.saved.relativenumber
    vim.wo.signcolumn = zen_state.saved.signcolumn
    vim.wo.foldcolumn = zen_state.saved.foldcolumn
    vim.wo.foldenable = zen_state.saved.foldenable
    local gs = package.loaded.gitsigns
    if gs then
      gs.toggle_signs(true)
    end
    zen_state.active = false
    return
  end

  zen_state.saved.laststatus = vim.o.laststatus
  zen_state.saved.showtabline = vim.o.showtabline
  zen_state.saved.cmdheight = vim.o.cmdheight
  zen_state.saved.number = vim.wo.number
  zen_state.saved.relativenumber = vim.wo.relativenumber
  zen_state.saved.signcolumn = vim.wo.signcolumn
  zen_state.saved.foldcolumn = vim.wo.foldcolumn
  zen_state.saved.foldenable = vim.wo.foldenable

  vim.o.laststatus = 0
  vim.o.showtabline = 0
  vim.o.cmdheight = 0
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = 'no'
  vim.wo.foldcolumn = '1'
  vim.wo.foldenable = false
  local gs = package.loaded.gitsigns
  if gs then
    gs.toggle_signs(false)
  end
  zen_state.active = true
end

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

  terminal.close_runner()
  sbcl.close_output()
  vim.cmd.cclose()
  vim.cmd.lclose()
end

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

map('n', '<C-M-j>', ':m .+1<CR>==', { desc = 'Move line down', silent = true })
map('n', '<C-M-k>', ':m .-2<CR>==', { desc = 'Move line up', silent = true })
map('v', '<C-M-j>', ":m '>+1<CR>gv=gv", { desc = 'Move line down', silent = true })
map('v', '<C-M-k>', ":m '<-2<CR>gv=gv", { desc = 'Move line up', silent = true })
map('v', '<leader>ss', ':s/\\C\\%V', { desc = 'Search only selection' })
map('n', '<leader>w', '<cmd>update<CR>', { desc = 'Save file' })
map('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' })
map('v', '<leader>r', '"hy:%s/\\C\\v<C-r>h//g<left><left>', { desc = 'Replace selection' })
map('n', '<leader>vc', '<cmd>edit $MYVIMRC<CR>', { desc = 'Edit config' })
map('v', '<', '<gv', { desc = 'Indent left' })
map('v', '>', '>gv', { desc = 'Indent right' })
map('x', 'p', '"_dP', { desc = 'Paste without yank' })
map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down centered' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up centered' })
map('n', 'n', 'nzzzv<cmd>redrawstatus<cr>', { desc = 'Next search result' })
map('n', 'N', 'Nzzzv<cmd>redrawstatus<cr>', { desc = 'Previous search result' })

map('n', '<leader>d', hide_buffer, { desc = 'Hide buffer' })
map('n', '<leader>D', delete_buffer, { desc = 'Delete buffer' })
map('n', '<leader>bo', '<cmd>BufCloseOthers<CR>', { desc = 'Close other buffers' })

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

map('n', '<leader><Tab>', '<C-^>', { desc = 'Alternate buffer' })
map('n', '<leader>j', '<cmd>bnext<CR>', { desc = 'Next buffer' })
map('n', '<leader>k', '<cmd>bprev<CR>', { desc = 'Previous buffer' })
map('n', "'", '`', { desc = 'Go to mark exact' })
map('n', '`', "'", { desc = 'Go to mark line' })

map('i', '<C-a>', '<C-o>^', { desc = 'Beginning of line' })
map('i', '<C-e>', '<End>', { desc = 'End of line' })
map('i', '<C-h>', '<Left>', { desc = 'Move left' })
map('i', '<C-j>', '<Down>', { desc = 'Move down' })
map('i', '<C-k>', '<Up>', { desc = 'Move up' })
map('i', '<C-l>', '<Right>', { desc = 'Move right' })

map({ 'i', 's' }, '<C-y>', function()
  if vim.snippet.active() then
    vim.snippet.stop()
    return
  end

  local key = vim.api.nvim_replace_termcodes('<C-y>', true, false, true)
  vim.api.nvim_feedkeys(key, 'n', false)
end, { desc = 'Stop snippet or default' })

map('t', '<C-w>', '<C-w>', { desc = 'Window prefix', noremap = true })
map('t', '<C-u>', '<C-u>', { desc = 'Scroll up', noremap = true })
map('t', '<C-a>', '<C-a>', { desc = 'Line start', noremap = true })
map('t', '<C-e>', '<C-e>', { desc = 'Line end', noremap = true })
map('t', '<C-k>', '<C-k>', { desc = 'Kill to end', noremap = true })

map('n', '<leader>zz', toggle_zen_mode, { desc = 'Toggle zen mode' })

map('n', 'cn', '<cmd>cnext<CR>', { desc = 'Quickfix next' })
map('n', 'cp', '<cmd>cprev<CR>', { desc = 'Quickfix prev' })
map('n', 'co', '<cmd>copen<CR>', { desc = 'Quickfix open' })
map('n', 'cm', function()
  if vim.tbl_isempty(vim.fn.getqflist()) then
    print 'Quickfix is empty'
    return
  end

  require('fzf-lua').quickfix()
end, { desc = 'Quickfix fzf' })

map('n', 'cq', close_special_windows, { desc = 'Close diagnostics', silent = true })

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

if vim.g.neovide then
  local default_scale = vim.g.neovide_scale_factor or 1.0
  local step = 0.1

  map('n', '<C-=>', function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + step
  end, { desc = 'Zoom in' })

  map('n', '<C-->', function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - step
  end, { desc = 'Zoom out' })

  map('n', '<C-0>', function()
    vim.g.neovide_scale_factor = default_scale
  end, { desc = 'Reset zoom' })

  map('n', '<A-i>', '<cmd>split | terminal fish<cr>i', { desc = 'Horizontal split terminal' })
end

map('n', '<leader>sp', '<cmd>Lazy<cr>', { desc = 'Lazy' })
map('n', '<leader>sc', '<cmd>ConformInfo<cr>', { desc = 'Conform info' })
map('n', '<leader>sl', '<cmd>LspInfo<cr>', { desc = 'LSP info' })
map('n', '<leader>sr', '<cmd>LspRestart<cr>', { desc = 'Restart LSP' })
map('n', '<leader>xP', ':LPush ', { desc = 'Push cwd and cd', silent = false })
map('n', '<leader>xp', '<cmd>LPop<cr>', { desc = 'Pop cwd' })
map('n', '<leader>uws', '<cmd>TrimWhitespaceToggleOnSave<cr>', { desc = 'Toggle trim on save' })
