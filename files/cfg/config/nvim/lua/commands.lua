local map = vim.keymap.set
local colorcolumn = require 'self.colorcolumn'

------ @CWD Stack ------

local cd_stack = {}

local function get_cd_stack()
  return cd_stack
end

vim.api.nvim_create_user_command('LPush', function(opts)
  local stack = get_cd_stack()
  local current = vim.fn.getcwd(-1, -1)
  stack[#stack + 1] = current

  if opts.args == '' then
    vim.notify('LPush: ' .. current, vim.log.levels.INFO)
    return
  end

  local dir = vim.fn.fnamemodify(vim.fn.expand(opts.args), ':p')
  if vim.fn.isdirectory(dir) ~= 1 then
    table.remove(stack)
    vim.notify('LPush: not a directory: ' .. dir, vim.log.levels.ERROR)
    return
  end

  vim.cmd('cd ' .. vim.fn.fnameescape(dir))
  vim.notify('LPush: ' .. current .. ' -> ' .. dir, vim.log.levels.INFO)
end, { desc = 'Push Global CWD', force = true, nargs = '?', complete = 'dir' })

vim.api.nvim_create_user_command('LPop', function()
  local stack = get_cd_stack()
  local dir = table.remove(stack)

  if not dir or dir == '' then
    vim.notify('LPop: stack empty', vim.log.levels.WARN)
    return
  end

  vim.cmd('cd ' .. vim.fn.fnameescape(dir))
  vim.notify('LPop: ' .. dir, vim.log.levels.INFO)
end, { desc = 'Pop global cwd', force = true })

map('n', '<leader>xP', ':LPush ', { desc = 'Push cwd and cd', silent = false })
map('n', '<leader>xp', '<cmd>LPop<cr>', { desc = 'Pop cwd' })

map('n', '<C-M-j>', ':m .+1<CR>==', { desc = 'Move line down', silent = true })
map('n', '<C-M-k>', ':m .-2<CR>==', { desc = 'Move line up', silent = true })
map('v', '<C-M-j>', ":m '>+1<CR>gv=gv", { desc = 'Move line down', silent = true })
map('v', '<C-M-k>', ":m '<-2<CR>gv=gv", { desc = 'Move line up', silent = true })
map('v', '<leader>ss', ':s/\\C\\%V', { desc = 'Search only selection' })
map('n', '<leader>w', '<cmd>update<CR>', { desc = 'Save file' })
map('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' })
map('v', '<leader>r', '"hy:%s/\\C\\v<C-r>h//g<left><left>', { desc = 'Replace selection' })

------ @Colorcolumn ------

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
