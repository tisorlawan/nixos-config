-- stylua: ignore start
vim.g.mapleader = ' '
local function get_color_mode()
  local mode = vim.env.COLOR or vim.env.LC_COLOR

  if mode ~= 'dark' and mode ~= 'light' then
    local color_file = io.open(vim.fn.expand '~/.color', 'r')
    if color_file then
      mode = (color_file:read '*a' or ''):gsub('%s+', '')
      color_file:close()
    end
  end

  if mode ~= 'dark' and mode ~= 'light' then
    mode = 'dark'
  end

  return mode
end

vim.g.monochrome_mode = get_color_mode()
math.randomseed(os.time())

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
---@diagnostic disable-next-line: undefined-field
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath }
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- @OPTIONS
-- ============================================================================

-- Indentation
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.linebreak = true
-- vim.opt.breakindent = true
vim.opt.virtualedit = 'block'
vim.opt.jumpoptions = 'stack'
vim.opt.smoothscroll = true

-- Search
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.g.disable_autocomplete = true

-- General
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.backspace = { 'indent', 'eol', 'start' }
vim.opt.wildmode = 'longest:full,full'
vim.opt.cursorline = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.winborder = 'rounded'

-- Files
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = true
local undodir = vim.fn.stdpath 'state' .. '/undo'
vim.fn.mkdir(undodir, 'p')
vim.opt.undodir = undodir

-- Performance
vim.opt.lazyredraw = true
vim.opt.updatetime = 300
vim.opt.ttimeoutlen = 0

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.inccommand = 'split'

-- UI
vim.opt.showmatch = true
vim.opt.ruler = true
vim.opt.laststatus = 2
vim.opt.shortmess:append 'S'
vim.opt.title = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', extends = '→', precedes = '←' }
vim.opt.showbreak = '↪'

vim.wo.foldcolumn = '0'

-- Path & Wildignore
vim.opt.path = '.,**'
vim.opt.wildignore:append '**/node_modules/**,**/.git/**,**/dist/**,**/build/**,**/__pycache__/**,*.pyc,*.o,*.obj,*.d'

vim.opt.grepprg = 'rg --vimgrep --smart-case'
vim.opt.grepformat = '%f:%l:%c:%m'

vim.filetype.add({
  pattern = {
    ['%.env%.[%w_.-]+'] = 'sh',
  },
  extension = {
    lisp = 'lisp',
    cl = 'lisp',
    lsp = 'lisp',
    asd = 'lisp',
  },
  filename = {
    ['sbclrc'] = 'lisp',
    ['.sbclrc'] = 'lisp',
  },
})

-- ============================================================================
-- @KEYMAPS - GENERAL
-- ============================================================================

local map = vim.keymap.set

local function set_random_colorscheme(choices_str)
  local choices = {}
  for choice in choices_str:gmatch '([^,%s]+)' do
    table.insert(choices, choice)
  end
  if #choices == 0 then
    return
  end
  math.randomseed(os.time())
  local choice = choices[math.random(#choices)]
  vim.g.random_colorscheme = choice
  vim.cmd('colorscheme ' .. choice)
end

local terminal_buf = nil

map('n', '<C-M-j>', ':m .+1<CR>==', { desc = 'Move line down', silent = true })
map('n', '<C-M-k>', ':m .-2<CR>==', { desc = 'Move line up', silent = true })
map('v', '<C-M-j>', ":m '>+1<CR>gv=gv", { desc = 'Move Line Down in Visual Mode', silent = true })
map('v', '<C-M-k>', ":m '<-2<CR>gv=gv", { desc = 'Move Line Up in Visual Mode', silent = true })
map('v', '<leader>ss', ':s/\\C\\%V', { desc = 'Search only in visual selection using %V atom' })
map('n', '<leader>w', '<cmd>update<CR>', { desc = 'Save file' })
map('n', '<leader>h', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
map('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' })
map('v', '<leader>r', '"hy:%s/\\C\\v<C-r>h//g<left><left>', { desc = 'change selection' })
map('n', '<leader>vc', '<cmd>edit $MYVIMRC<CR>', { desc = 'Edit vimrc' })
map('v', '<', '<gv', { desc = 'Indent left' })
map('v', '>', '>gv', { desc = 'Indent right' })
map('x', 'p', '"_dP', { desc = 'Paste without yank' })
map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down centered' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up centered' })
map('n', 'n', 'nzzzv<cmd>redrawstatus<cr>', { desc = 'Next search centered' })
map('n', 'N', 'Nzzzv<cmd>redrawstatus<cr>', { desc = 'Prev search centered' })

-- ============================================================================
-- @BUFFER MANAGEMENT
-- ============================================================================

local function bufhide()
  local buf = vim.api.nvim_get_current_buf()
  local alt = vim.fn.bufnr '#'
  if alt ~= -1 and alt ~= buf and vim.fn.buflisted(alt) == 1 then
    vim.cmd('buffer ' .. alt)
  else
    vim.cmd 'bnext'
  end
  if vim.api.nvim_get_current_buf() == buf then
    vim.cmd 'enew'
  end
end

local function bufdelete()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].modified then
    print 'Buffer has unsaved changes.'
    return
  end
  local alt = vim.fn.bufnr '#'
  if alt ~= -1 and alt ~= buf and vim.fn.buflisted(alt) == 1 then
    vim.cmd('buffer ' .. alt)
  else
    vim.cmd 'bnext'
  end
  if vim.api.nvim_get_current_buf() == buf then
    vim.cmd 'enew'
  end
  ---@diagnostic disable-next-line: param-type-mismatch
  pcall(vim.cmd, 'bwipeout ' .. buf)
end

map('n', '<leader>d', bufhide, { desc = 'Hide buffer' })
map('n', '<leader>D', bufdelete, { desc = 'Delete buffer' })
-- stylua: ignore end

-- ============================================================================
-- @KEYMAPS - PATH/FILE UTILS
-- ============================================================================

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
  local dir = vim.fn.expand '%:.:h'
  if dir == '' or dir == '.' then
    dir = ''
  else
    dir = dir .. '/'
  end
  local filepath = vim.fn.input('New file: ', dir, 'file')
  if filepath ~= '' and filepath ~= dir then
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

-- ============================================================================
-- @KEYMAPS - NAVIGATION
-- ============================================================================

-- Buffer navigation
map('n', '<leader><Tab>', '<C-^>', { desc = 'Alternate buffer' })
map('n', '<leader>j', '<cmd>bnext<CR>', { desc = 'Next buffer' })
map('n', '<leader>k', '<cmd>bprev<CR>', { desc = 'Previous buffer' })

-- Mark navigation (swap ' and `)
map('n', "'", '`', { desc = 'Go to mark (exact)' })
map('n', '`', "'", { desc = 'Go to mark (line)' })

-- Insert mode navigation
map('i', '<C-a>', '<C-o>^', { desc = 'Begin of line (non-blank)' })
map('i', '<C-e>', '<End>', { desc = 'End of line' })
map('i', '<C-h>', '<Left>', { desc = 'Move left' })
map('i', '<C-j>', '<Down>', { desc = 'Move down' })
map('i', '<C-k>', '<Up>', { desc = 'Move up' })
map('i', '<C-l>', '<Right>', { desc = 'Move right' })

map({ 'i', 's' }, '<C-y>', function()
  if vim.snippet.active() then
    vim.snippet.stop()
  else
    local key = vim.api.nvim_replace_termcodes('<C-y>', true, false, true)
    vim.api.nvim_feedkeys(key, 'n', false)
  end
end, { desc = 'Stop snippet or default' })

-- ============================================================================
-- @KEYMAPS - TERMINAL
-- ============================================================================

map('t', '<C-w>', '<C-w>', { noremap = true, desc = 'Window prefix' })
map('t', '<C-u>', '<C-u>', { noremap = true, desc = 'Scroll up' })
map('t', '<C-a>', '<C-a>', { noremap = true, desc = 'Begin of line' })
map('t', '<C-e>', '<C-e>', { noremap = true, desc = 'End of line' })
map('t', '<C-k>', '<C-k>', { noremap = true, desc = 'Kill to end' })

-- ============================================================================
-- @ZEN MODE
-- ============================================================================

local zen_state = {
  active = false,
  saved = {},
}

local function zen_toggle()
  if zen_state.active then
    -- Restore
    vim.o.laststatus = zen_state.saved.laststatus
    vim.o.showtabline = zen_state.saved.showtabline
    vim.o.cmdheight = zen_state.saved.cmdheight
    vim.wo.number = zen_state.saved.number
    vim.wo.relativenumber = zen_state.saved.relativenumber
    vim.wo.signcolumn = zen_state.saved.signcolumn
    vim.wo.foldcolumn = zen_state.saved.foldcolumn
    zen_state.active = false
  else
    -- Save and hide
    zen_state.saved.laststatus = vim.o.laststatus
    zen_state.saved.showtabline = vim.o.showtabline
    zen_state.saved.cmdheight = vim.o.cmdheight
    zen_state.saved.number = vim.wo.number
    zen_state.saved.relativenumber = vim.wo.relativenumber
    zen_state.saved.signcolumn = vim.wo.signcolumn
    zen_state.saved.foldcolumn = vim.wo.foldcolumn

    vim.o.laststatus = 0
    vim.o.showtabline = 0
    vim.o.cmdheight = 0
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = 'no'
    vim.wo.foldcolumn = '1'
    zen_state.active = true
  end
end

map('n', '<leader>zz', zen_toggle, { desc = 'Toggle zen mode' })

-- ============================================================================
-- @AUTOCMDS
-- ============================================================================

local augroup = vim.api.nvim_create_augroup('UserConfig', { clear = true })

vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 1 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  callback = function()
    vim.highlight.on_yank { timeout = 150 }
  end,
})

-- stylua: ignore
local colorcolumn_rules = {
  gitcommit = { enable = false, limits = { 50, 72 } },
  markdown  = { enable = false, limits = { 80 } },
  python    = { enable = false, limits = { 88 } },
}

local function parse_colorcolumn(input)
  local cols = {}
  for value in input:gmatch '[^,%s]+' do
    local num = tonumber(value)
    if not num or num < 1 then
      return nil
    end
    table.insert(cols, tostring(math.floor(num)))
  end
  if #cols == 0 then
    return nil
  end
  return table.concat(cols, ',')
end

local function default_colorcolumn_for_filetype(ft)
  local rule = colorcolumn_rules[ft]
  if not rule or not rule.enable or not rule.limits or #rule.limits == 0 then
    return ''
  end
  return table.concat(vim.tbl_map(tostring, rule.limits), ',')
end

local function apply_colorcolumn_rule()
  vim.wo.colorcolumn = default_colorcolumn_for_filetype(vim.bo.filetype)
end

vim.api.nvim_create_user_command('ColorColumnToggle', function(cmd_opts)
  if vim.wo.colorcolumn ~= '' then
    vim.wo.colorcolumn = ''
    return
  end
  local parsed = cmd_opts.args ~= '' and parse_colorcolumn(cmd_opts.args) or nil
  local default = default_colorcolumn_for_filetype(vim.bo.filetype)
  if default == '' then
    default = '80'
  end
  vim.wo.colorcolumn = parsed or default
end, { nargs = '?', force = true, desc = 'Toggle colorcolumn in current window' })

vim.api.nvim_create_user_command('ColorColumnSet', function(cmd_opts)
  local parsed = parse_colorcolumn(cmd_opts.args)
  if not parsed then
    vim.notify('ColorColumnSet: expected positive integer columns, e.g. 80 or 80,100', vim.log.levels.ERROR)
    return
  end
  vim.wo.colorcolumn = parsed
end, { nargs = 1, force = true, desc = 'Set colorcolumn in current window' })

vim.api.nvim_create_user_command('ColorColumnClear', function()
  vim.wo.colorcolumn = ''
end, { force = true, desc = 'Clear colorcolumn in current window' })

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = vim.tbl_keys(colorcolumn_rules),
  callback = function()
    apply_colorcolumn_rule()
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'lua', 'javascript', 'typescript', 'typescriptreact', 'javascriptreact', 'html', 'css', 'haskell', 'sh', 'nix' },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'lisp',
  callback = function()
    vim.opt_local.smartindent = false
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.bo.lisp = false
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'scheme',
  callback = function()
    vim.opt_local.smartindent = false
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.bo.lisp = true
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'go',
  callback = function()
    vim.opt_local.expandtab = false
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'markdown',
  callback = function()
    vim.opt_local.spell = false
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'qf',
  callback = function()
    vim.keymap.set('n', 'q', '<cmd>cclose<CR>', { buffer = true, desc = 'Close quickfix' })
  end,
})

local function fix_dirvish_leftcol(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= 'dirvish' then
    return
  end
  local win = vim.fn.bufwinid(buf)
  if win == -1 or not vim.api.nvim_win_is_valid(win) then
    return
  end
  vim.api.nvim_win_call(win, function()
    local row = vim.fn.line '.'
    local col = vim.fn.col '.'
    if col > 1 then
      vim.api.nvim_win_set_cursor(0, { row, 0 })
    end
    local view = vim.fn.winsaveview()
    if view.leftcol ~= 0 then
      view.leftcol = 0
      vim.fn.winrestview(view)
    end
  end)
end

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'dirvish',
  callback = function(event)
    vim.opt_local.sidescrolloff = 0
    vim.opt_local.sidescroll = 1
    vim.keymap.set('n', '-', function()
      vim.defer_fn(function()
        fix_dirvish_leftcol(vim.api.nvim_get_current_buf())
      end, 1)
      return (vim.v.count > 0 and tostring(vim.v.count) or '') .. '<Plug>(dirvish_up)'
    end, { buffer = event.buf, expr = true, remap = true, silent = true })
    vim.schedule(function()
      fix_dirvish_leftcol(event.buf)
    end)
  end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
  group = augroup,
  callback = function(event)
    if vim.api.nvim_buf_is_valid(event.buf) and vim.bo[event.buf].filetype == 'dirvish' then
      fix_dirvish_leftcol(event.buf)
    end
  end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  group = augroup,
  callback = function()
    if vim.bo.filetype ~= 'qf' then
      return
    end
    local qf = vim.fn.getqflist { title = 1 }
    local title = qf.title or ''
    if title:match '^Grep:' then
      return
    end
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(buf, '[Quickfix]')
  end,
})

local sh_scratch_buf = nil
local sh_scratch_win = nil

local function run_sh_scratch()
  local file = vim.fn.expand '%:p'
  if file == '' then
    return
  end
  if not vim.fn.executable(file) then
    vim.fn.system('chmod +x ' .. vim.fn.shellescape(file))
  end

  local output = vim.fn.systemlist(vim.fn.shellescape(file))
  local exit_code = vim.v.shell_error
  local cur_win = vim.api.nvim_get_current_win()

  if not sh_scratch_buf or not vim.api.nvim_buf_is_valid(sh_scratch_buf) then
    vim.cmd(vim.api.nvim_win_get_width(0) > vim.api.nvim_win_get_height(0) * 1.5 and 'vnew' or 'new')
    sh_scratch_buf = vim.api.nvim_get_current_buf()
    sh_scratch_win = vim.api.nvim_get_current_win()
    vim.bo[sh_scratch_buf].buftype = 'nofile'
    vim.bo[sh_scratch_buf].bufhidden = 'wipe'
    vim.api.nvim_set_current_win(cur_win)
  elseif not sh_scratch_win or not vim.api.nvim_win_is_valid(sh_scratch_win) then
    vim.cmd(vim.api.nvim_win_get_width(0) > vim.api.nvim_win_get_height(0) * 1.5 and 'vsplit' or 'split')
    vim.api.nvim_win_set_buf(0, sh_scratch_buf)
    sh_scratch_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(cur_win)
  end

  local content = {}
  if exit_code ~= 0 then
    table.insert(content, '[Exit: ' .. exit_code .. ']')
    table.insert(content, '---')
  end
  vim.list_extend(content, #output > 0 and output or { '(no output)' })

  vim.bo[sh_scratch_buf].modifiable = true
  vim.api.nvim_buf_set_lines(sh_scratch_buf, 0, -1, false, content)
  vim.bo[sh_scratch_buf].modifiable = false
  vim.bo[sh_scratch_buf].readonly = true
end

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'sh',
  callback = function()
    vim.keymap.set('n', '<CR>', run_sh_scratch, { buffer = true, desc = 'Run shell script in scratch' })
    vim.api.nvim_create_autocmd('BufWritePost', {
      buffer = vim.api.nvim_get_current_buf(),
      callback = function()
        if sh_scratch_buf and vim.api.nvim_buf_is_valid(sh_scratch_buf) then
          run_sh_scratch()
        end
      end,
    })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'help', 'man', 'lspinfo', 'checkhealth', 'notify', 'spectre_panel' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
  end,
})

vim.api.nvim_create_autocmd('VimResized', {
  group = augroup,
  callback = function()
    vim.cmd 'tabdo wincmd ='
  end,
})

-- ============================================================================
-- @QUICKFIX
-- ============================================================================

map('n', 'cn', '<cmd>cnext<CR>', { desc = 'Quickfix next' })
map('n', 'cp', '<cmd>cprev<CR>', { desc = 'Quickfix prev' })
map('n', 'co', '<cmd>copen<CR>', { desc = 'Quickfix open' })
map('n', 'cm', function()
  local qflist = vim.fn.getqflist()
  if #qflist == 0 then
    print 'Quickfix is empty'
    return
  end
  require('fzf-lua').quickfix()
end, { desc = 'Quickfix fzf' })

-- ============================================================================
-- @CLOSE DIAGNOSTICS/SPECIAL WINDOWS
-- ============================================================================

local function close_diagnostics()
  local windows = vim.api.nvim_list_wins()
  for _, win in ipairs(windows) do
    vim.api.nvim_win_call(win, function()
      local bt = vim.bo.buftype
      local ft = vim.bo.filetype
      local buf = vim.api.nvim_get_current_buf()

      if bt == 'quickfix' then
        vim.cmd 'lclose'
      elseif bt == 'locationlist' then
        vim.cmd 'cclose'
      elseif bt == 'help' then
        vim.cmd 'bdelete'
      elseif ft == 'trouble' then
        vim.cmd 'bdelete'
      elseif ft == 'toggleterm' then
        vim.cmd 'close'
      elseif ft == 'neo-tree-popup' then
        vim.cmd 'close'
      elseif ft == 'Outline' then
        vim.cmd 'close'
      elseif buf == terminal_buf and vim.api.nvim_buf_is_valid(buf) then
        vim.cmd('bdelete! ' .. buf)
        terminal_buf = nil
      end
    end)
  end
  vim.cmd 'cclose'
end

map('n', 'cq', close_diagnostics, { desc = 'close diagnostics', silent = true })

-- ============================================================================
-- @TERMINAL RUNNER
-- ============================================================================

local last_shell_cmd = ''

local function clear_last_shell_command()
  last_shell_cmd = ''
  if vim.bo.filetype == 'rust' then
    last_shell_cmd = 'cargo check'
    print 'Reset to default: cargo check'
  else
    print 'Cleared last command'
  end
end

local terminal_cmd = ''

local function open_terminal_with_cmd(cmd)
  local need_split = true

  if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
    local term_win = vim.fn.bufwinid(terminal_buf)
    if term_win ~= -1 then
      vim.api.nvim_set_current_win(term_win)
      need_split = false
      vim.cmd 'enew'
    end
    pcall(vim.api.nvim_buf_delete, terminal_buf, { force = true })
  end

  if need_split then
    vim.cmd 'vsplit'
    vim.cmd 'enew'
  end

  terminal_cmd = cmd
  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function(_, exit_code, _)
      vim.schedule(function()
        if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
          local win = vim.fn.bufwinid(terminal_buf)
          if win ~= -1 then
            vim.wo[win].statusline = '%#StatusLine# !' .. terminal_cmd .. ' [exit: ' .. exit_code .. '] %='
          end
        end
      end)
    end,
  })
  terminal_buf = vim.api.nvim_get_current_buf()
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { buffer = terminal_buf })

  local win = vim.api.nvim_get_current_win()
  vim.wo[win].statusline = '%#StatusLine# !' .. cmd .. ' %='
end

local function run_in_terminal()
  local cmd = last_shell_cmd
  if cmd == '' then
    if vim.bo.filetype == 'rust' then
      cmd = 'cargo check'
    else
      print 'No previous command'
      return
    end
    last_shell_cmd = cmd
  end
  -- Replace % with current filename
  local filename = vim.fn.expand '%:.'
  cmd = cmd:gsub('%%', filename)
  local cur_win = vim.api.nvim_get_current_win()
  open_terminal_with_cmd(cmd)
  vim.api.nvim_set_current_win(cur_win)
end

local function edit_and_run_in_terminal()
  local filename = vim.fn.expand '%:.'
  local default_cmd = last_shell_cmd:gsub('%%', filename)
  local cmd = vim.fn.input('$ ', default_cmd)
  if cmd ~= '' then
    cmd = cmd:gsub('%%', filename)
    last_shell_cmd = cmd
    open_terminal_with_cmd(cmd)
  end
end

map('n', '<leader><leader>', edit_and_run_in_terminal, { desc = 'Run shell command' })
map('n', '<leader>rr', run_in_terminal, { desc = 'Re-run last command' })
map('n', '<leader>re', edit_and_run_in_terminal, { desc = 'Edit and run command' })
map('n', '<leader>rx', clear_last_shell_command, { desc = 'Clear last command' })

-- ============================================================================
-- @FUZZY FINDER (fzf/fzy)
-- ============================================================================

local fzf_tempfile = vim.fn.tempname()
local fzf_source_win = 0

local fuzzy_finder_cache = nil
local function get_fuzzy_finder()
  if fuzzy_finder_cache ~= nil then
    return fuzzy_finder_cache
  end
  if vim.fn.executable 'fzf' == 1 then
    fuzzy_finder_cache = 'fzf'
  elseif vim.fn.executable 'fzy' == 1 then
    fuzzy_finder_cache = 'fzy'
  else
    fuzzy_finder_cache = ''
  end
  return fuzzy_finder_cache
end

local function open_picker_terminal(cmd, name, on_done, height)
  height = height or 15
  local width = math.floor(vim.o.columns * 0.6)
  local float_height = math.floor(vim.o.lines * 0.4)
  local row = math.floor((vim.o.lines - float_height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local use_float = vim.fn.has 'nvim-0.9' == 1
  local term_buf = vim.api.nvim_create_buf(false, true)
  local term_win

  if use_float then
    term_win = vim.api.nvim_open_win(term_buf, true, {
      relative = 'editor',
      width = width,
      height = float_height,
      row = row,
      col = col,
      style = 'minimal',
      border = 'rounded',
      title = ' ' .. name .. ' ',
      title_pos = 'center',
    })
  else
    vim.cmd('botright ' .. height .. 'new')
    term_buf = vim.api.nvim_get_current_buf()
    term_win = vim.api.nvim_get_current_win()
    vim.wo[term_win].statusline = '%#StatusLine# ' .. name .. ' %='
  end

  vim.bo[term_buf].bufhidden = 'wipe'
  vim.fn.jobstart({ 'sh', '-c', cmd }, {
    term = true,
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(term_buf) then
          vim.api.nvim_buf_delete(term_buf, { force = true })
        end
        if on_done then
          on_done()
        end
      end)
    end,
  })
  vim.cmd 'startinsert'
end

local function fzf_callback(lines)
  if #lines > 0 and lines[1] ~= '' and vim.fn.filereadable(lines[1]) == 1 then
    if vim.fn.win_gotoid(fzf_source_win) == 1 then
      vim.cmd('edit ' .. vim.fn.fnameescape(lines[1]))
    end
  end
end

-- ============================================================================
-- @GREP (ripgrep/grep)
-- ============================================================================

local function grep_picker(query)
  local search_term = query
  local additional_flags = ''

  -- Only parse -g flags from the end of query to avoid false positives
  -- Format: "search term -g *.lua -g !*.test.lua"
  while true do
    local glob_start = search_term:match '.*() %-g [^ ]+$'
    if not glob_start then
      break
    end
    local glob_part = search_term:sub(glob_start + 4) -- skip ' -g '
    additional_flags = ' -g ' .. vim.fn.shellescape(glob_part) .. additional_flags
    search_term = search_term:sub(1, glob_start - 1)
  end

  local mode_flags = ' --fixed-strings'
  local actual_term = search_term

  local prefix_match = search_term:match '^([ri]+):'
  if prefix_match then
    actual_term = search_term:sub(#prefix_match + 2)
    if prefix_match:find 'i' then
      mode_flags = mode_flags .. ' --ignore-case'
    end
    if prefix_match:find 'r' then
      mode_flags = mode_flags:gsub(' %-%-fixed%-strings', '')
    end
  end

  local escaped_term = vim.fn.shellescape(actual_term)
  local cmd
  if vim.fn.executable 'rg' == 1 then
    cmd = 'rg --vimgrep --smart-case' .. mode_flags .. additional_flags .. ' -- ' .. escaped_term
  else
    cmd = 'grep -rnI ' .. escaped_term .. ' .'
  end

  local output = vim.fn.systemlist(cmd)

  if #output == 0 then
    print('No matches found for: ' .. query)
    return
  elseif #output == 1 then
    local file, line, col = output[1]:match '([^:]+):(%d+):(%d+):'
    if not file then
      file, line = output[1]:match '([^:]+):(%d+):'
      col = 1
    end

    if file and line and vim.fn.filereadable(file) == 1 then
      ---@diagnostic disable-next-line: param-type-mismatch
      local ok = pcall(vim.cmd, { cmd = 'drop', args = { file } })
      if not ok then
        vim.cmd.edit(vim.fn.fnameescape(file))
      end
      vim.api.nvim_win_set_cursor(0, { tonumber(line), tonumber(col) - 1 })
      vim.cmd 'normal! zz'
      vim.cmd('redraw | echo "No other match for: ' .. search_term:gsub('"', '\\"') .. '"')
    elseif file then
      print('File not found: ' .. file)
    end
    return
  end

  vim.fn.setqflist({}, 'r', {
    title = 'Grep: ' .. query,
    lines = output,
    efm = '%f:%l:%c:%m,%f:%l:%m',
  })

  vim.cmd 'copen'
  vim.api.nvim_buf_set_name(0, ' ' .. actual_term .. ' [' .. #output .. ']')
  vim.cmd 'echo ""'
end

local function get_visual_selection()
  vim.cmd 'noau normal! "vy'
  local text = vim.fn.getreg 'v'
  vim.fn.setreg('v', {})
  return text
end

map('v', '<leader>l', function()
  local text = get_visual_selection()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)

  if text ~= '' then
    text = text:gsub('\n', ' ')
    grep_picker(text)
  end
end, { desc = 'Grep selection' })

map('v', '<leader>L', function()
  local text = get_visual_selection()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)

  if text ~= '' then
    text = text:gsub('\n', ' ')
    local query = vim.fn.input('Grep: ', text)
    if query ~= '' then
      grep_picker(query)
    end
  end
end, { desc = 'Grep selection with prompt' })

map('n', '<leader>ll', function()
  local query = vim.fn.input 'Grep: '
  if query ~= '' then
    grep_picker(query)
  end
end, { desc = 'Grep prompt' })

function _G.grep_operator(type)
  local save = vim.fn.getreg '"'
  local save_type = vim.fn.getregtype '"'
  if type == 'char' then
    vim.cmd 'noau normal! `[v`]y'
  elseif type == 'line' then
    vim.cmd "noau normal! '[V']y"
  else
    return
  end
  local text = vim.fn.getreg('"'):gsub('\n', ' ')
  vim.fn.setreg('"', save, save_type)
  if text ~= '' then
    grep_picker(text)
  end
end

map('n', '<leader>l', function()
  vim.o.operatorfunc = 'v:lua.grep_operator'
  return 'g@'
end, { noremap = true, silent = true, expr = true, desc = 'Grep operator' })

map('n', '<leader>lw', function()
  vim.o.operatorfunc = 'v:lua.grep_operator'
  return 'g@iw'
end, { noremap = true, silent = true, expr = true, desc = 'Grep word under cursor' })

map('n', '<leader>sp', '<cmd>Lazy<cr>', { desc = 'Lazy' })
map('n', '<leader>sc', '<cmd>ConformInfo<cr>', { desc = 'Conform Info' })
map('n', '<leader>sl', '<cmd>LspInfo<cr>', { desc = 'LSP Info' })
map('n', '<leader>sr', '<cmd>LspRestart<cr>', { desc = 'LSP Restart' })

vim.api.nvim_create_user_command('Grep', function(cmd_opts)
  grep_picker(cmd_opts.args)
end, { nargs = 1, force = true })

-- ============================================================================
-- @HARPOON (file bookmarks)
-- ============================================================================

local harpoon_files = {}
local harpoon_dir = vim.fn.expand '~/.vim/harpoon'

local function harpoon_get_file()
  local cwd = vim.fn.getcwd()
  local hash = vim.fn.sha256(cwd):sub(1, 16)
  if vim.fn.isdirectory(harpoon_dir) == 0 then
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.fn.mkdir(harpoon_dir, 'p', tonumber('755', 8))
  end
  return harpoon_dir .. '/' .. hash
end

local function harpoon_load()
  local file = harpoon_get_file()
  if vim.fn.filereadable(file) == 1 then
    harpoon_files = vim.fn.readfile(file)
  else
    harpoon_files = {}
  end
end

local function harpoon_save()
  vim.fn.writefile(harpoon_files, harpoon_get_file())
end

local function harpoon_add()
  harpoon_load()
  local file = vim.fn.expand '%:.'
  if file == '' then
    print 'No file'
    return
  end
  local found = false
  for _, f in ipairs(harpoon_files) do
    if f == file then
      found = true
      break
    end
  end
  if not found then
    table.insert(harpoon_files, file)
    harpoon_save()
    print('Harpooned (' .. #harpoon_files .. '): ' .. file)
  else
    for i, f in ipairs(harpoon_files) do
      if f == file then
        print('Already harpooned (' .. i .. ')')
        break
      end
    end
  end
end

local function harpoon_save_from_buf(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  harpoon_files = vim.tbl_filter(function(line)
    return line ~= ''
  end, lines)
  harpoon_save()
end

local function harpoon_edit()
  harpoon_load()

  local width = math.floor(vim.o.columns * 0.5)
  local height = math.min(#harpoon_files + 2, math.floor(vim.o.lines * 0.4))
  height = math.max(height, 5)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, harpoon_files)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Harpoon ',
    title_pos = 'center',
  })

  vim.bo[buf].buftype = 'acwrite'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_name(buf, '[Harpoon]')

  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = buf,
    callback = function()
      harpoon_save_from_buf(buf)
      vim.bo[buf].modified = false
      print 'Harpoon saved'
    end,
  })

  vim.keymap.set('n', 'q', function()
    harpoon_save_from_buf(buf)
    vim.api.nvim_win_close(win, true)
    print 'Harpoon saved'
  end, { buffer = buf })

  vim.keymap.set('n', '<Esc>', function()
    harpoon_save_from_buf(buf)
    vim.api.nvim_win_close(win, true)
    print 'Harpoon saved'
  end, { buffer = buf })
end

local function harpoon_remove()
  harpoon_load()
  local file = vim.fn.expand '%:.'
  if file == '' then
    print 'No file'
    return
  end
  local idx = nil
  for i, f in ipairs(harpoon_files) do
    if f == file then
      idx = i
      break
    end
  end
  if idx then
    table.remove(harpoon_files, idx)
    harpoon_save()
    print('Removed: ' .. file)
  else
    print 'Not harpooned'
  end
end

local function harpoon_go(idx)
  harpoon_load()
  if idx <= #harpoon_files and idx > 0 then
    local file = harpoon_files[idx]
    if vim.fn.filereadable(file) == 1 then
      vim.cmd('edit ' .. vim.fn.fnameescape(file))
    else
      print('File not found: ' .. file)
    end
  else
    print('No harpoon at ' .. idx)
  end
end

local function harpoon_menu()
  harpoon_load()
  if #harpoon_files == 0 then
    print 'No harpooned files'
    return
  end
  fzf_source_win = vim.api.nvim_get_current_win()
  local finder = get_fuzzy_finder()
  if finder ~= '' then
    fzf_tempfile = vim.fn.tempname()
    local list = table.concat(harpoon_files, '\n')
    local cmd = 'echo ' .. vim.fn.shellescape(list) .. ' | ' .. finder .. ' > ' .. fzf_tempfile

    open_picker_terminal(cmd, '[Harpoon]', function()
      if vim.fn.filereadable(fzf_tempfile) == 1 then
        local lines = vim.fn.readfile(fzf_tempfile)
        vim.fn.delete(fzf_tempfile)
        fzf_callback(lines)
      end
    end)
  else
    for i, f in ipairs(harpoon_files) do
      print(i .. ': ' .. f)
    end
  end
end

-- stylua: ignore start
map('n', '<leader>oa', harpoon_add, { desc = 'Harpoon add' })
map('n', '<leader>or', harpoon_remove, { desc = 'Harpoon remove' })
map('n', '<leader>oe', harpoon_edit, { desc = 'Harpoon edit' })
map('n', '<leader>om', harpoon_menu, { desc = 'Harpoon menu' })
map('n', '<M-1>', function() harpoon_go(1) end, { desc = 'Harpoon 1' })
map('n', '<M-2>', function() harpoon_go(2) end, { desc = 'Harpoon 2' })
map('n', '<M-3>', function() harpoon_go(3) end, { desc = 'Harpoon 3' })
map('n', '<M-4>', function() harpoon_go(4) end, { desc = 'Harpoon 4' })
map('n', '<M-5>', function() harpoon_go(5) end, { desc = 'Harpoon 5' })
-- stylua: ignore end

-- ============================================================================
-- @SEMICOLON INSERT (C-d)
-- ============================================================================

local semicolon_filetypes = { 'c', 'cpp', 'rust', 'java', 'javascript', 'typescript', 'typescriptreact', 'css', 'php', 'go', 'zig' }

map('i', '<C-d>', function()
  local ft = vim.bo.filetype
  local found = false
  for _, t in ipairs(semicolon_filetypes) do
    if t == ft then
      found = true
      break
    end
  end
  if not found then
    return ''
  end
  local line = vim.fn.getline '.'
  if line:sub(-1) ~= ';' then
    return '<End>;'
  end
  return '<End>'
end, { expr = true, desc = 'Append semicolon' })

-- ============================================================================
-- @UI & ICONS
-- ============================================================================

local ui = {
  icons = {
    diagnostics = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' },
    git = { added = ' ', modified = ' ', removed = ' ' },
    kinds = {
      Array = ' ',
      Boolean = '󰨙 ',
      Class = ' ',
      Color = ' ',
      Constant = '󰏿 ',
      Constructor = ' ',
      Enum = ' ',
      EnumMember = ' ',
      Event = ' ',
      Field = ' ',
      File = ' ',
      Folder = ' ',
      Function = '󰊕 ',
      Interface = ' ',
      Key = ' ',
      Keyword = ' ',
      Method = '󰊕 ',
      Module = ' ',
      Namespace = '󰦮 ',
      Null = ' ',
      Number = '󰎠 ',
      Object = ' ',
      Operator = ' ',
      Package = ' ',
      Property = ' ',
      Reference = ' ',
      Snippet = ' ',
      String = ' ',
      Struct = '󰆼 ',
      Text = ' ',
      TypeParameter = ' ',
      Unit = ' ',
      Value = ' ',
      Variable = '󰀫 ',
    },
  },
}

function ui.fg(name)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  local fg = hl and hl.fg
  return fg and { fg = string.format('#%06x', fg) } or nil
end

-- ============================================================================
-- @USED FILETYPES SYSTEM
-- ============================================================================

local function get_used_ft()
  local fts = {}
  local fpath = vim.fn.stdpath 'config' .. '/ft'
  local f = io.open(fpath, 'r')
  if f then
    for line in f:lines() do
      local trimmed = line:gsub('^%s*(.-)%s*$', '%1')
      if #trimmed > 0 and trimmed:sub(1, 1) ~= '#' and trimmed:sub(1, 4) ~= 'vim:' then
        table.insert(fts, trimmed)
      end
    end
    f:close()
  end

  local config = {
    lisp = {},
    c = { formatters = { 'clang_format' }, servers = { 'clangd' } },
    go = { formatters = { 'gofumpt', 'goimports', 'golines' }, servers = { 'gopls' } },
    html = { servers = { 'html' }, formatters = { 'oxfmt' } },
    javascript = { formatters = { 'oxfmt' } },
    json = { formatters = { 'oxfmt' } },
    lua = { formatters = { 'stylua' }, servers = { 'lua_ls' } },
    markdown = { formatters = { 'oxfmt' }, servers = { 'marksman' } },
    nix = { servers = { 'nil_ls' }, formatters = { 'nixpkgs_fmt' } },
    php = { formatters = { 'php_cs_fixer' }, servers = { 'phpactor', 'html' } },
    -- python = { formatters = { 'ruff_format', 'ruff_organize_imports' }, servers = { 'pyright', 'ruff' } },
    python = { formatters = { 'ruff_format', 'ruff_organize_imports' }, servers = { 'pyright', 'ruff' } },
    rust = { servers = { 'rust_analyzer' }, formatters = { 'rustfmt' } },
    sh = { servers = { 'bashls' }, formatters = { 'shfmt' } },
    typescript = { formatters = { 'oxfmt' }, servers = { 'ts_ls', 'eslint' } },
    typescriptreact = { formatters = { 'oxfmt' }, servers = { 'ts_ls', 'eslint' } },
    zig = { formatters = { 'zigfmt' }, servers = { 'zls' } },
  }

  local formatters_by_ft = {}
  for _, ft in ipairs(fts) do
    if config[ft] and config[ft].formatters then
      formatters_by_ft[ft] = config[ft].formatters
    end
  end

  return { used_ft = fts, config = config, formatters_by_ft = formatters_by_ft }
end

local used_ft_sys = get_used_ft()
local enabled_ft = {}
for _, ft in ipairs(used_ft_sys.used_ft) do
  enabled_ft[ft] = true
end
local lisp_enabled = enabled_ft.lisp == true
local markdown_enabled = enabled_ft.markdown == true

-- ============================================================================
-- @LSP
-- ============================================================================

vim.opt.signcolumn = 'yes:1'

local function setup_lsp_keymaps(buf)
  local function lmap(key, fn, desc)
    vim.keymap.set('n', key, fn, { desc = desc, buffer = buf, silent = true })
  end
  lmap('gd', vim.lsp.buf.definition, 'Goto Definition')
  lmap('gi', vim.lsp.buf.implementation, 'Goto Implementation')
  lmap('gy', vim.lsp.buf.type_definition, 'Goto Type Definition')
  lmap('gr', vim.lsp.buf.references, 'Goto References')
  lmap('gD', vim.lsp.buf.declaration, 'Goto Declaration')
  lmap('K', function()
    vim.lsp.buf.hover { border = 'rounded' }
  end, 'Hover')
  lmap('<leader>k', function()
    vim.lsp.buf.signature_help { border = 'rounded' }
  end, 'Signature Help')
  lmap('<leader>cr', vim.lsp.buf.rename, 'Rename')
  lmap('[d', function()
    vim.diagnostic.jump { count = -1, float = { border = 'rounded' } }
  end, 'Prev Diagnostic')
  lmap(']d', function()
    vim.diagnostic.jump { count = 1, float = { border = 'rounded' } }
  end, 'Next Diagnostic')
  lmap('<leader>ci', vim.lsp.buf.incoming_calls, 'Incoming calls')
  lmap('<leader>co', vim.lsp.buf.outgoing_calls, 'Outgoing calls')
end

local function on_attach(client, bufnr)
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  setup_lsp_keymaps(bufnr)
  client.server_capabilities.semanticTokensProvider = nil
end

local function setup_diagnostic()
  vim.diagnostic.config {
    virtual_text = false,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = ui.icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN] = ui.icons.diagnostics.Warn,
        [vim.diagnostic.severity.HINT] = ui.icons.diagnostics.Hint,
        [vim.diagnostic.severity.INFO] = ui.icons.diagnostics.Info,
      },
    },
    float = {
      border = 'rounded',
      ---@diagnostic disable-next-line: assign-type-mismatch
      source = 'always',
      header = 'Diagnostics:',
      prefix = function(diagnostic, i, _)
        local severity = vim.diagnostic.severity[diagnostic.severity]
        local level = severity:sub(1, 1) .. severity:sub(2):lower()
        return string.format('%d. ', i), 'DiagnosticFloating' .. level
      end,
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  }
end

setup_diagnostic()

vim.keymap.set('n', '<leader>ud', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = 'Toggle diagnostics' })

vim.keymap.set('n', 'gl', function()
  vim.diagnostic.open_float { border = 'rounded' }
end, { desc = 'Show line diagnostics' })

-- ============================================================================
-- @LSP SERVERS (native vim.lsp)
-- ============================================================================

local lsp_servers = {
  bashls = {
    cmd = { 'bash-language-server', 'start' },
    filetypes = { 'bash', 'sh' },
    root_markers = { '.git' },
  },
  basedpyright = {
    cmd = { 'basedpyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
    settings = {
      basedpyright = {
        analysis = {
          autoImportCompletions = false,
          autoSearchPaths = false,
          useLibraryCodeForTypes = false,
          diagnosticMode = 'openFilesOnly',
        },
      },
    },
  },
  pyright = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
    settings = {
      pyright = {
        analysis = {
          autoImportCompletions = false,
          autoSearchPaths = false,
          useLibraryCodeForTypes = false,
          diagnosticMode = 'openFilesOnly',
        },
      },
    },
  },
  clangd = {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
    root_markers = { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', '.git' },
  },
  eslint = {
    cmd = { 'vscode-eslint-language-server', '--stdio' },
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue', 'svelte', 'astro' },
    root_markers = { '.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.json', 'eslint.config.js', 'eslint.config.mjs', 'package.json' },
  },
  gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.mod', 'go.work', '.git' },
  },
  html = {
    cmd = { 'vscode-html-language-server', '--stdio' },
    filetypes = { 'html', 'php' },
    root_markers = { 'package.json', '.git' },
    init_options = {
      provideFormatter = true,
      embeddedLanguages = { css = true, javascript = true },
      configurationSection = { 'html', 'css', 'javascript' },
    },
  },
  lua_ls = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.stylua.toml', 'stylua.toml', '.git' },
    settings = {
      Lua = {
        diagnostics = { globals = { 'vim' } },
        workspace = {
          library = vim.api.nvim_get_runtime_file('', true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  },
  marksman = {
    cmd = { 'marksman', 'server' },
    filetypes = { 'markdown' },
    root_markers = { '.marksman.toml', '.git' },
  },
  nil_ls = {
    cmd = { 'nil' },
    filetypes = { 'nix' },
    root_markers = { 'flake.nix', '.git' },
  },
  phpactor = {
    cmd = { 'phpactor', 'language-server' },
    filetypes = { 'php' },
    root_markers = { 'composer.json', '.git' },
  },
  ruff = {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  },
  rust_analyzer = {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', 'rust-project.json' },
    settings = {
      ['rust-analyzer'] = {
        completion = {
          callable = {
            snippets = 'none',
          },
        },
      },
    },
  },
  ts_ls = {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
    init_options = {
      hostInfo = 'neovim',
      plugins = {
        {
          name = '@effect/language-service',
          location = vim.fn.getcwd() .. '/node_modules',
        },
      },
      preferences = {
        includePackageJsonAutoImports = 'on',
      },
    },
  },
  zls = {
    cmd = { 'zls' },
    filetypes = { 'zig' },
    root_markers = { 'build.zig', 'zls.json', '.git' },
  },
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(event)
    on_attach(vim.lsp.get_client_by_id(event.data.client_id), event.buf)
  end,
})

local function setup_lsp()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  vim.lsp.config('*', { capabilities = capabilities })

  local servers_to_enable = {}
  for _, ft in ipairs(used_ft_sys.used_ft) do
    for _, server in ipairs((used_ft_sys.config[ft] or {}).servers or {}) do
      if lsp_servers[server] and not vim.tbl_contains(servers_to_enable, server) then
        table.insert(servers_to_enable, server)
      end
    end
  end

  for _, server in ipairs(servers_to_enable) do
    vim.lsp.config(server, lsp_servers[server])
  end
  vim.lsp.enable(servers_to_enable)
end

setup_lsp()

vim.api.nvim_create_user_command('LspInfo', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  local enabled = vim.tbl_keys(lsp_servers)
  table.sort(enabled)

  local lines = {
    string.rep('=', 60),
    'vim.lsp',
    '',
    'Active Clients:',
  }
  if #clients == 0 then
    table.insert(lines, '  (none)')
  else
    for _, c in ipairs(clients) do
      table.insert(lines, string.format('  - %s (id=%d, root=%s)', c.name, c.id, c.root_dir or '?'))
    end
  end

  table.insert(lines, '')
  table.insert(lines, 'Configured Servers:')
  for _, name in ipairs(enabled) do
    local cfg = lsp_servers[name]
    local exe = cfg.cmd and cfg.cmd[1] or '?'
    local ok = vim.fn.executable(exe) == 1
    table.insert(lines, string.format('  %s %s%s', ok and '+' or '-', name, ok and '' or ' (not installed)'))
    table.insert(lines, string.format('      cmd: %s', table.concat(cfg.cmd or {}, ' ')))
    table.insert(lines, string.format('      filetypes: %s', table.concat(cfg.filetypes or {}, ', ')))
    table.insert(lines, string.format('      root_markers: %s', table.concat(cfg.root_markers or {}, ', ')))
    if cfg.settings then
      for _, line in ipairs(vim.split(vim.inspect(cfg.settings), '\n')) do
        table.insert(lines, '      ' .. line)
      end
    end
    if cfg.init_options then
      table.insert(lines, '      init_options:')
      for _, line in ipairs(vim.split(vim.inspect(cfg.init_options), '\n')) do
        table.insert(lines, '        ' .. line)
      end
    end
  end

  vim.cmd 'tabnew'
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_name(buf, '[LspInfo]')
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.keymap.set('n', 'q', '<cmd>tabclose<cr>', { buffer = buf, silent = true })
end, { force = true })

vim.api.nvim_create_user_command('LspRestart', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
    vim.lsp.stop_client(client.id)
  end
  vim.defer_fn(function()
    for _, name in ipairs(names) do
      ---@diagnostic disable-next-line: param-type-mismatch
      vim.lsp.enable(name, { bufnr = bufnr })
    end
    vim.notify(string.format('Restarted %d LSP client(s): %s', #names, table.concat(names, ', ')), vim.log.levels.INFO)
  end, 500)
end, { force = true })

local sbcl_virt_ns = vim.api.nvim_create_namespace 'sbcl_eval'

local function sbcl_send(expr, label, on_result)
  local uv = vim.uv or vim.loop
  local client = uv.new_tcp()
  local function notify_result(msg, level)
    vim.schedule(function()
      if on_result then
        on_result(msg, level)
      else
        vim.notify(msg, level)
      end
    end)
  end
  client:connect('127.0.0.1', 5555, function(err)
    if err then
      notify_result(label .. ': connection failed', vim.log.levels.ERROR)
      pcall(client.close, client)
      return
    end
    client:read_start(function(_, data)
      if not data then
        pcall(client.close, client)
        return
      end
      client:read_stop()
      client:write(expr .. '\n', function(write_err)
        if write_err then
          notify_result(label .. ': send failed', vim.log.levels.ERROR)
          pcall(client.close, client)
          return
        end
        client:read_start(function(_, resp)
          pcall(client.shutdown, client)
          pcall(client.close, client)
          if not resp then
            return
          end
          local trimmed = vim.trim(resp)
          if trimmed:match '^ERR ' then
            notify_result(label .. ': ' .. trimmed:sub(5), vim.log.levels.ERROR)
          elseif trimmed:match '^OK ' then
            notify_result(trimmed:sub(4), vim.log.levels.INFO)
          else
            notify_result(trimmed, vim.log.levels.INFO)
          end
        end)
      end)
    end)
  end)
end

local function sbcl_show_virt(msg, level)
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local hl = level == vim.log.levels.ERROR and 'DiagnosticVirtualTextError' or 'DiagnosticVirtualTextInfo'
  vim.api.nvim_buf_clear_namespace(bufnr, sbcl_virt_ns, 0, -1)
  vim.api.nvim_buf_set_extmark(bufnr, sbcl_virt_ns, row, 0, {
    virt_text = { { ' => ' .. msg, hl } },
    virt_text_pos = 'eol',
  })
  vim.defer_fn(function()
    pcall(vim.api.nvim_buf_clear_namespace, bufnr, sbcl_virt_ns, 0, -1)
  end, 3000)
end

vim.api.nvim_create_user_command('SbclLoadFile', function()
  local ft = vim.bo.filetype
  if ft ~= 'lisp' and ft ~= 'commonlisp' then
    vim.notify('SbclLoadFile: not a lisp file (ft=' .. ft .. ')', vim.log.levels.ERROR)
    return
  end
  local filepath = vim.fn.expand '%:p'
  if filepath == '' then
    vim.notify('SbclLoadFile: no file in current buffer', vim.log.levels.ERROR)
    return
  end
  sbcl_send(string.format('(load "%s")', filepath), 'SbclLoadFile')
end, { force = true })

local function sbcl_eval_expr(on_result)
  local ft = vim.bo.filetype
  if ft ~= 'lisp' and ft ~= 'commonlisp' then
    vim.notify('SbclEvalExpr: not a lisp file (ft=' .. ft .. ')', vim.log.levels.ERROR)
    return
  end
  local save = vim.fn.winsaveview()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local char = line:sub(col + 1, col + 1)
  local prev_char = col > 0 and line:sub(col, col) or ''
  local start, finish

  if char == '(' then
    start = { row, col + 1 }
    vim.fn.cursor(row, col + 1)
    finish = vim.fn.searchpairpos('(', '', ')', 'nW')
  elseif char == ')' then
    finish = { row, col + 1 }
    vim.fn.cursor(row, col + 1)
    start = vim.fn.searchpairpos('(', '', ')', 'bnW')
  elseif prev_char == ')' then
    finish = { row, col }
    vim.fn.cursor(row, col)
    start = vim.fn.searchpairpos('(', '', ')', 'bnW')
  else
    start = vim.fn.searchpairpos('(', '', ')', 'bnW')
    if start[1] ~= 0 then
      vim.fn.cursor(start[1], start[2])
      finish = vim.fn.searchpairpos('(', '', ')', 'nW')
    end
  end

  vim.fn.winrestview(save)

  if not start or start[1] == 0 or not finish or finish[1] == 0 then
    vim.notify('SbclEvalExpr: no expression found', vim.log.levels.ERROR)
    return
  end

  local lines = vim.api.nvim_buf_get_text(0, start[1] - 1, start[2] - 1, finish[1] - 1, finish[2], {})
  local expr = table.concat(lines, ' ')
  sbcl_send(expr, 'SbclEvalExpr', on_result)
end

vim.api.nvim_create_user_command('SbclEvalExpr', function()
  sbcl_eval_expr()
end, { force = true })

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lisp', 'commonlisp' },
  callback = function(ev)
    vim.keymap.set('n', '<C-x><C-x>', '<cmd>write | SbclLoadFile<cr>', { buffer = ev.buf, silent = true })
    vim.keymap.set('i', '<C-x><C-x>', function()
      vim.cmd 'write'
      vim.cmd 'SbclLoadFile'
      vim.cmd 'startinsert'
    end, { buffer = ev.buf, silent = true })
    vim.keymap.set('n', '<C-x><C-e>', '<cmd>SbclEvalExpr<cr>', { buffer = ev.buf, silent = true })
    vim.keymap.set('i', '<C-x><C-e>', function()
      sbcl_eval_expr(sbcl_show_virt)
      vim.cmd 'startinsert'
    end, { buffer = ev.buf, silent = true })
  end,
})

-- ============================================================================
-- @PLUGINS (lazy.nvim)
-- ============================================================================

if not vim.g.__user_lazy_setup_done then
  require('lazy').setup({
    -- 1. @COLORSCHEME
    { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
    {
      'jpwol/thorn.nvim',
      opts = {
        styles = {
          keywords = { italic = false, bold = false },
          comments = { italic = true, bold = false },
          strings = { italic = false, bold = true },

          diagnostic = {
            underline = false,
            error = { highlight = false },
          },
        },
      },
    },
    { 'rebelot/kanagawa.nvim' },
    { 'oskarnurm/koda.nvim' },
    { 'yonatan-perel/lake-dweller.nvim' },

    -- 2. CORE ENGINE
    {
      'nvim-treesitter/nvim-treesitter',
      main = 'nvim-treesitter.configs',
      branch = 'master',
      build = ':TSUpdate',
      dependencies = {
        { 'yioneko/nvim-yati', event = { 'BufReadPost', 'BufNewFile' } },
        { 'windwp/nvim-ts-autotag' },
      },
      lazy = false,
      opts = {
        ensure_installed = {
          'bash',
          'clojure',
          'commonlisp',
          'diff',
          'html',
          'lua',
          'luadoc',
          'markdown',
          'markdown_inline',
          'python',
          'vim',
          'vimdoc',
        },
        auto_install = true,
        -- ignore_install = { 'gitcommit' },
        highlight = { enable = true, additional_vim_regex_highlighting = true and { 'ruby', 'elixir' } or false },
        indent = {
          enable = true,
          disable = { 'clojure', 'c', 'css', 'heex', 'javascript', 'json', 'lua', 'lisp', 'python', 'rust', 'scheme', 'toml', 'tsx', 'typescript', 'yaml' },
        },
        yati = { enable = true, disable = { 'rust', 'cpp' }, default_lazy = true, default_fallback = 'auto' },
      },
    },

    {
      'stevearc/conform.nvim',
      opts = {
        formatters_by_ft = used_ft_sys.formatters_by_ft,
        format_on_save = function(bufnr)
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          return { timeout_ms = 500, lsp_fallback = true }
        end,
      },
      config = function(_, conform_opts)
        require('conform').setup(conform_opts)
        vim.api.nvim_create_user_command('ToggleAutoFormat', function()
          vim.b.disable_autoformat = not vim.b.disable_autoformat
          print((vim.b.disable_autoformat and '-disabled-' or '-enabled-') .. ' auto format')
        end, { force = true })
        vim.keymap.set('n', '<leader>uf', '<cmd>ToggleAutoFormat<cr>', { desc = 'toggle autoformat' })
        vim.keymap.set('n', '<leader>ua', function()
          vim.g.disable_autocomplete = not vim.g.disable_autocomplete
          print((vim.g.disable_autocomplete and '-disabled-' or '-enabled-') .. ' autocomplete')
        end, { desc = 'toggle autocomplete' })
      end,
    },

    -- 3. COMPLETION
    {
      'saghen/blink.cmp',
      version = '*',
      opts = {
        keymap = {
          preset = 'super-tab',
          ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
          ['<C-e>'] = { 'hide', 'fallback' },
          ['<Tab>'] = {
            function(cmp)
              if cmp.snippet_active() then
                return cmp.accept()
              else
                return cmp.select_and_accept()
              end
            end,
            'snippet_forward',
            'fallback',
          },
          ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
          ['<Up>'] = { 'select_prev', 'fallback' },
          ['<Down>'] = { 'select_next', 'fallback' },
          ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
          ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
          ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
          ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
          ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
        },
        appearance = { kind_icons = ui.icons.kinds },
        completion = {
          list = {
            selection = {
              preselect = function(_)
                return not require('blink.cmp').snippet_active { direction = 1 }
              end,
              auto_insert = true,
            },
          },
          trigger = {
            show_in_snippet = false,
            prefetch_on_insert = true,
          },
          menu = {
            auto_show = function(_)
              return not vim.g.disable_autocomplete
            end,
            border = 'rounded',
            draw = {
              columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
            },
          },
          documentation = { auto_show = true, window = { min_width = 10, max_width = 100, max_height = 30, border = 'rounded' } },
          ghost_text = { enabled = false },
        },
        signature = { enabled = false },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
          providers = {
            path = {
              opts = {
                get_cwd = function(_)
                  return vim.fn.getcwd()
                end,
              },
            },
          },
        },
      },
    },

    -- 4. NAVIGATION & PICKERS
    {
      'ibhagwan/fzf-lua',
      event = { 'BufReadPre', 'BufNewFile', 'VimEnter' },
    -- stylua: ignore
    keys = {
      { '<C-n>', function() require('fzf-lua').buffers()  end,    desc = 'Buffers' },
      { '<leader>fF', function() require('fzf-lua').files { cwd = vim.fn.getcwd() } end,    desc = 'Find Files (cwd)' },
      { '<leader>fg', function() require('fzf-lua').git_files() end,                        desc = 'Find Files (git-files)' },
      { '<leader>fr', function() require('fzf-lua').oldfiles() end,                         desc = 'Recent' },
      { '<leader>fR', function() require('fzf-lua').oldfiles { cwd = vim.fn.getcwd() } end, desc = 'Recent (cwd)' },
      { '<leader>gc', function() require('fzf-lua').git_commits() end,                      desc = 'Commits' },
      { '<leader>gs', function() require('fzf-lua').git_status() end,                       desc = 'Status' },
      { '<leader>fy', function() require('fzf-lua').registers() end,                        desc = 'Registers' },
      { '<leader>fx', function() require('fzf-lua').diagnostics_document() end,             desc = 'Document Diagnostics' },
      { '<leader>fX', function() require('fzf-lua').diagnostics_workspace() end,            desc = 'Workspace Diagnostics' },
      { '<leader>fm', function() require('fzf-lua').marks() end,                            desc = 'Marks' },
      { '<leader>fM', function() require('fzf-lua').man_pages() end,                        desc = 'Man Pages' },
      { '<leader>f.', function() require('fzf-lua').resume() end,                           desc = 'Resume' },
      { '<leader>ss', function() require('fzf-lua').lsp_document_symbols() end,             desc = 'Goto Symbol' },
      { '<leader>S',  function() require('fzf-lua').lsp_workspace_symbols() end,            desc = 'Goto Symbol (Workspace)' },
      { '<leader>uC', function() require('fzf-lua').colorschemes() end,                     desc = 'Colorscheme with Preview' },
      { '<leader>cs', function() require('fzf-lua').lsp_document_symbols() end,             desc = 'Document symbols' },
      { '<leader>cw', function() require('fzf-lua').lsp_live_workspace_symbols() end,       desc = 'Workspace symbols' },
      { '<leader>ca', function() require('fzf-lua').lsp_code_actions() end,                 desc = 'Code actions' },
      {
        '<leader>fd',
        function()
          require('fzf-lua').fzf_exec(
            'fd -u --type d -E .cache -E snap -E cache -E go -E .git -E .npm -E .miniconda3 -E .conda -E __pycache__ -E .docker -E .cargo -E .cert -E .windsurf -E .minikube -E .ghcup -E .claude -E .stack -E .cabal -E .aws -E tmp -E .rustup -E uv -E .local/share -E .codeium -E .cargo_build_artifacts -E .ipython -E .ruff_cache -E .venv -E Slack -E node_modules -E .jupyter -E nltk_data -E .local/state -E .zoom',
            {
              prompt = '~/',
              cwd = '~',
              actions = {
                ['default'] = function(selected)
                  if selected and #selected > 0 then
                    local root = vim.fn.expand '~' .. '/'
                    vim.cmd('cd ' .. root .. selected[1])
                    require('fzf-lua').files()
                  end
                end
              }
            })
        end,
        desc = 'Fuzzy cd to dir under ~'
      },
    },
      config = function()
        local actions = require 'fzf-lua.actions'
        vim.cmd [[FzfLua register_ui_select]]
        require('fzf-lua').setup {
          winopts = { backdrop = 100, preview = { delay = 0 } },
          manpages = {
            previewer = 'man',
            actions = {
              ['default'] = function(selected)
                if not selected or not selected[1] then
                  return
                end
                local manpage = require('fzf-lua.providers.manpages').manpage_vim_arg(selected[1])
                vim.cmd('vert Man ' .. manpage)
              end,
            },
          },
          helptags = { previewer = 'help_tags' },
          lsp = { code_actions = { previewer = 'codeaction' } },
          files = {
            fd_opts = [[--color never --type f --hidden --follow --strip-cwd-prefix -E .git -E .jj -E node_modules -E .venv -E .sqlx -E resource_snapshots ]],
          },
          grep = {
            rg_opts = '--column --line-number --no-heading --color=never --smart-case --max-columns=4096 -e',
            winopts = { treesitter = { enabled = false } },
            actions = { ['ctrl-g'] = { actions.grep_lgrep }, ['ctrl-r'] = { actions.toggle_ignore } },
          },
          defaults = { git_icons = true, file_icons = true },
          keymap = { fzf = { ['ctrl-q'] = 'select-all+accept', ['ctrl-y'] = 'toggle-preview', ['ctrl-x'] = 'abort' } },
          complete_path = { cmd = 'fd -u --exclude .git --exclude .ipynb_checkpoints --exclude .sqlx --exclude node_modules --exclude resource_snapshots' },
        }
        vim.keymap.set({ 'i' }, '<C-x><C-f>', function()
          require('fzf-lua').complete_path()
        end, { silent = true, desc = 'Fuzzy complete path' })
      end,
    },
    {
      'dmtrKovalenko/fff.nvim',
      build = function()
        require('fff.download').download_or_build_binary()
      end,
      opts = { prompt = '> ' },
      keys = {
        {
          '<c-p>',
          function()
            require('fff').find_files()
          end,
          desc = 'Open file picker',
        },
        {
          '<leader>sg',
          function()
            require('fff').live_grep()
          end,
          desc = 'LiFFFe grep',
        },
        {
          '<leader>fz',
          function()
            require('fff').live_grep {
              grep = {
                modes = { 'fuzzy', 'plain' },
              },
            }
          end,
          desc = 'Live fffuzy grep',
        },
      },
    },
    {
      'justinmk/vim-dirvish',
      event = 'VeryLazy',
      dependencies = { 'roginfarrer/vim-dirvish-dovish' },
      lazy = false,
    },
    {
      'nvim-neo-tree/neo-tree.nvim',
      keys = { { '<Leader>e', ':Neotree source=filesystem reveal=true position=right toggle<Cr>', desc = 'Neotree toggle', silent = true } },
      dependencies = { 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim' },
      opts = function()
        local function copy_path(state)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          local filename = node.name
          local modify = vim.fn.fnamemodify
          local results = { filepath, modify(filepath, ':.'), modify(filepath, ':~'), filename, modify(filename, ':r'), modify(filename, ':e') }
          local options = {
            { label = 'Absolute path', value = results[1] },
            { label = 'Path relative to CWD', value = results[2] },
            { label = 'Path relative to HOME', value = results[3] },
            { label = 'Filename', value = results[4] },
            { label = 'Filename without extension', value = results[5] },
            { label = 'Extension', value = results[6] },
          }
          vim.ui.select(options, {
            prompt = 'Choose to copy to clipboard:',
            format_item = function(item)
              return string.format('%s: %s', item.label, item.value)
            end,
          }, function(choice)
            if choice then
              vim.fn.setreg('+', choice.value)
              vim.notify('Copied: ' .. choice.value)
            end
          end)
        end
        local function open_with_relative_path(state)
          local node = state.tree:get_node()
          if node.type == 'directory' then
            require('neo-tree.sources.filesystem.commands').toggle_node(state)
            return
          end
          if node.type ~= 'file' then
            return
          end
          local abs_path = node:get_id()
          local target_buf = vim.fn.bufnr(abs_path)
          if target_buf ~= -1 then
            local win = vim.fn.bufwinid(target_buf)
            if win ~= -1 then
              vim.api.nvim_set_current_win(win)
              return
            end
          end
          local path = abs_path
          local rel = vim.fn.fnamemodify(abs_path, ':.')
          if not rel:match '^%.%.' then
            path = rel
          end
          -- Check if neo-tree is the only window, create a new one first
          local wins = vim.api.nvim_list_wins()
          local real_wins = vim.tbl_filter(function(w)
            local buf = vim.api.nvim_win_get_buf(w)
            local bt = vim.bo[buf].buftype
            return bt ~= 'nofile' and bt ~= 'prompt'
          end, wins)
          if #real_wins == 0 then
            vim.cmd 'vsplit'
          end
          vim.cmd('edit ' .. vim.fn.fnameescape(path))
        end
        return {
          close_if_last_window = true,
          enable_git_status = true,
          window = {
            mappings = {
              ['Y'] = copy_path,
              ['<cr>'] = open_with_relative_path,
              ['o'] = open_with_relative_path,
              ['<2-LeftMouse>'] = open_with_relative_path,
            },
          },
          filesystem = {
            follow_current_file = { enabled = false },
            use_libuv_file_watcher = true,
            hijack_netrw_behavior = 'disabled',
            filtered_items = { always_show = { '.gitignore' } },
          },
          default_component_configs = {
            icon = {
              folder_closed = ui.icons.kinds.Folder,
              folder_open = ui.icons.kinds.Folder,
              folder_empty = '󰜌',
              default = '*',
              highlight = 'NeoTreeFileIcon',
            },
          },
        }
      end,
    },
    {
      'mrjones2014/smart-splits.nvim',
      lazy = true,
    -- stylua: ignore
    keys = {
      { "<C-h>",      function() require("smart-splits").move_cursor_left() end,  { silent = true } },
      { "<C-j>",      function() require("smart-splits").move_cursor_down() end,  { silent = true } },
      { "<C-k>",      function() require("smart-splits").move_cursor_up() end,    { silent = true } },
      { "<C-l>",      function() require("smart-splits").move_cursor_right() end, { silent = true } },
      { "<C-left>",   function() require("smart-splits").resize_left() end,       { silent = true } },
      { "<C-right>",  function() require("smart-splits").resize_right() end,      { silent = true } },
      { "<C-up>",     function() require("smart-splits").resize_up() end,         { silent = true } },
      { "<C-down>",   function() require("smart-splits").resize_down() end,       { silent = true } },
      { "<leader>oh", function() require("smart-splits").swap_buf_left() end,     { silent = true }, desc = "Swap Left" },
      { "<leader>oj", function() require("smart-splits").swap_buf_down() end,     { silent = true }, desc = "Swap Down" },
      { "<leader>ok", function() require("smart-splits").swap_buf_up() end,       { silent = true }, desc = "Swap Up" },
      { "<leader>ol", function() require("smart-splits").swap_buf_right() end,    { silent = true }, desc = "Swap Right" },
    },
      config = function()
        require('smart-splits').setup { ignored_filetypes = { 'nofile', 'quickfix', 'qf', 'prompt' }, ignored_buftypes = { 'nofile' } }
      end,
    },
    {
      'https://codeberg.org/andyg/leap.nvim',
      keys = {
        { 's', '<Plug>(leap-forward)', mode = { 'n', 'x', 'o' }, desc = 'leap forward to' },
        { 'S', '<Plug>(leap-backward)', mode = { 'n', 'x', 'o' }, desc = 'leap backward to' },
        { 'x', '<Plug>(leap-forward-till)', mode = { 'x', 'o' }, desc = 'leap forward till' },
        { 'X', '<Plug>(leap-backward-till)', mode = { 'x', 'o' }, desc = 'leap backward till' },
        { 'gs', '<Plug>(leap-from-window)', mode = { 'n', 'x', 'o' }, desc = 'leap from window' },
      },
      dependencies = { 'tpope/vim-repeat' },
      config = function()
        local leap = require 'leap'
        leap.opts.safe_labels = 'tyuofghjklvbn'
        leap.opts.labels = 'sfnjklhowembuyvrgtqpcxz/SFNJKLHOWEIMBUYVRGTAQPCXZ'
      end,
    },
    {
      'ggandor/flit.nvim',
      event = { 'BufReadPost', 'BufNewFile' },
      keys = (function()
        local keys = {}
        for _, key in ipairs { 'f', 'F', 't', 'T' } do
          table.insert(keys, { key, mode = { 'n', 'x', 'o' }, desc = key })
        end
        return keys
      end)(),
      opts = { labeled_modes = 'nx' },
    },

    -- 5. UI COMPONENTS
    {
      'nvim-lualine/lualine.nvim',
      event = 'VeryLazy',
      init = function()
        vim.g.lualine_laststatus = vim.o.laststatus
        if vim.fn.argc(-1) > 0 then
          vim.o.statusline = ' '
        else
          vim.o.laststatus = 0
        end
      end,
      opts = function()
        local lualine_require = require 'lualine_require'
        lualine_require.require = require
        vim.o.laststatus = vim.g.lualine_laststatus

        return {
          options = {
            theme = 'auto',
            globalstatus = vim.o.laststatus == 3,
            disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'ministarter', 'snacks_dashboard' } },
            section_separators = '',
            component_separators = '',
          },
          sections = {
            lualine_a = { {
              'mode',
              fmt = function(str)
                return str:sub(1, 1)
              end,
            } },
            lualine_b = { 'branch' },
            lualine_c = {
              {
                function()
                  local path = vim.fn.expand '%:p'
                  local modified = vim.bo.modified and ' [+]' or ''
                  local readonly = vim.bo.readonly and ' [RO]' or ''
                  if path == '' then
                    return '[No Name]' .. modified .. readonly
                  end
                  local rel = vim.fn.fnamemodify(path, ':.')
                  -- Outside cwd: show full ~ path without truncation
                  if rel == path or rel:match '^%.%.' then
                    return vim.fn.fnamemodify(path, ':~') .. modified .. readonly
                  end
                  -- In cwd: truncate with max_depth only if path is long enough
                  local max_depth = 2
                  local min_len = 50
                  local parts = vim.split(rel, '/')
                  if #parts > max_depth + 1 and #rel >= min_len then
                    rel = parts[1] .. '/…/' .. parts[#parts]
                  end
                  return rel .. modified .. readonly
                end,
              },
              {
                'diagnostics',
                symbols = {
                  error = ui.icons.diagnostics.Error,
                  warn = ui.icons.diagnostics.Warn,
                  info = ui.icons.diagnostics.Info,
                  hint = ui.icons.diagnostics.Hint,
                },
              },
            },
            lualine_x = {
              {
                function()
                  return require('lsp-progress').progress()
                end,
              },
              {
                'diff',
                symbols = { added = ui.icons.git.added, modified = ui.icons.git.modified, removed = ui.icons.git.removed },
              },
            },
            lualine_y = {
              {
                'searchcount',
                maxcount = 999,
                timeout = 500,
              },
              { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
              { 'location', padding = { left = 0, right = 1 } },
            },
            lualine_z = {
              function()
                return ' ' .. os.date '%R'
              end,
            },
          },
          inactive_sections = {
            lualine_c = {
              {
                function()
                  local path = vim.fn.expand '%:p'
                  local modified = vim.bo.modified and ' [+]' or ''
                  local readonly = vim.bo.readonly and ' [RO]' or ''
                  if path == '' then
                    return '[No Name]' .. modified .. readonly
                  end
                  local rel = vim.fn.fnamemodify(path, ':.')
                  local display = (rel == path or rel:match '^%.%.') and vim.fn.fnamemodify(path, ':~') or rel
                  local max_depth = 2
                  local min_len = 50
                  local parts = vim.split(display, '/')
                  if #parts > max_depth + 1 and #display >= min_len then
                    local first = parts[1]
                    local filename = parts[#parts]
                    display = first .. '/…/' .. filename
                  end
                  return display .. modified .. readonly
                end,
              },
            },
          },
          extensions = { 'lazy' },
        }
      end,
    },
    {
      'echasnovski/mini.nvim',
      version = false,
      specs = { { 'nvim-tree/nvim-web-devicons', enabled = false, optional = true } },
      init = function()
        package.preload['nvim-web-devicons'] = function()
          require('mini.icons').mock_nvim_web_devicons()
          return package.loaded['nvim-web-devicons']
        end
      end,
      config = function()
        require('mini.icons').setup { style = 'glyph' }
      end,
    },
    {
      'lionyxml/gitlineage.nvim',
      dependencies = {
        'sindrets/diffview.nvim', -- optional, for open_diff feature
      },
      config = function()
        require('gitlineage').setup()
      end,
    },
    {
      'lewis6991/gitsigns.nvim',
      event = { 'BufReadPost', 'BufNewFile' },
      opts = {
        signs = {
          add = { text = '▎' },
          change = { text = '▎' },
          delete = { text = '' },
          topdelete = { text = '' },
          changedelete = { text = '▎' },
          untracked = { text = '▎' },
        },
        signs_staged = {
          add = { text = '│' },
          change = { text = '│' },
          delete = { text = '' },
          topdelete = { text = '' },
          changedelete = { text = '~' },
          untracked = { text = '│' },
        },
        on_attach = function(buffer)
          local gs = package.loaded.gitsigns
          local function lmap(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
          end
        -- stylua: ignore start
        lmap("n", "]h",
          function() if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end end,
          "Next Hunk")
        lmap("n", "[h",
          function() if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end end,
          "Prev Hunk")
        lmap("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        lmap("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
        lmap({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        lmap({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        lmap("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
        lmap("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
        lmap("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
        lmap("n", "<leader>hp", gs.preview_hunk, "Preview Hunk Inline")
        lmap("n", "<c-q>", gs.preview_hunk_inline, "Preview Hunk Inline")
        lmap("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line")
        lmap("n", "<leader>hB", function() gs.blame() end, "Blame Buffer")
        lmap("n", "<leader>hd", gs.diffthis, "Diff This")
        lmap("n", "<leader>hD", function() gs.diffthis("~") end, "Diff This ~")
        lmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
          -- stylua: ignore end
        end,
      },
    },
    {
      'f-person/git-blame.nvim',
      event = 'VeryLazy',
      keys = {
        { '<leader>gbo', '<cmd>GitBlameOpenCommitURL<cr>', desc = 'Open blame commit URL' },
        { '<leader>gbb', '<cmd>GitBlameToggle<cr>', desc = 'Toggle git blame' },
        { '<leader>gbe', '<cmd>GitBlameEnable<cr>', desc = 'Enable git blame' },
        { '<leader>gbd', '<cmd>GitBlameDisable<cr>', desc = 'Disable git blame' },
        { '<leader>gbs', '<cmd>GitBlameCopySHA<cr>', desc = 'Copy blame SHA' },
        { '<leader>gbc', '<cmd>GitBlameCopyCommitURL<cr>', desc = 'Copy blame commit URL' },
        { '<leader>gbp', '<cmd>GitBlameCopyPRURL<cr>', desc = 'Copy blame PR URL' },
        { '<leader>gbf', '<cmd>GitBlameOpenFileURL<cr>', desc = 'Open blame file URL' },
        { '<leader>gby', '<cmd>GitBlameCopyFileURL<cr>', desc = 'Copy blame file URL' },
      },
      opts = {
        enabled = false,
        message_template = ' <summary> • <date> • <author> • <<sha>>',
        date_format = '%d-%m-%Y %H:%M:%S',
        virtual_text_column = 1,
      },
    },
    {
      'kdheepak/lazygit.nvim',
      lazy = true,
      cmd = { 'LazyGit', 'LazyGitConfig', 'LazyGitCurrentFile', 'LazyGitFilter', 'LazyGitFilterCurrentFile' },
      keys = { { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' } },
      dependencies = { 'nvim-lua/plenary.nvim' },
    },

    -- 6. PRODUCTIVITY & EDITING
    {
      'kovisoft/slimv',
      enabled = lisp_enabled,
      ft = { 'lisp' },
      init = function()
        vim.g.slimv_keybindings = 0
        vim.g.slimv_unmap_cr = 1
        vim.g.slimv_unmap_tab = 1
        vim.g.slimv_unmap_space = 1
        vim.g.paredit_mode = 0
        vim.g.paredit_electric_return = 0
      end,
    },

    {
      'eraserhd/parinfer-rust',
      enabled = lisp_enabled and vim.fn.executable 'cargo' == 1,
      ft = { 'carp', 'clojure', 'dune', 'fennel', 'hy', 'janet', 'lisp', 'racket', 'scheme', 'wast', 'yuck' },
      build = 'cargo build --release',
      init = function()
        vim.g.parinfer_mode = 'smart'
      end,
    },

    {
      'MeanderingProgrammer/render-markdown.nvim',
      enabled = markdown_enabled,
      dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
      -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
      -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
      ---@module 'render-markdown'
      ---@type render.md.UserConfig
      opts = {
        enabled = false,
      },
    },

    {
      'windwp/nvim-autopairs',
      event = 'InsertEnter',
      config = function()
        require('nvim-autopairs').setup { disable_filetype = { 'TelescopePrompt', 'spectre_panel', 'lisp', 'scheme' } }
      end,
    },
    {
      'smoka7/multicursors.nvim',
      event = { 'BufReadPost', 'BufNewFile' },
      dependencies = { 'nvimtools/hydra.nvim' },
      opts = {},
      keys = { { mode = { 'v', 'n' }, '<Leader>m', '<Cmd>MCstart<CR>', desc = 'Create a selection for word under the cursor' } },
    },
    {
      'tisorlawan/vim-asterisk',
      config = function()
        vim.cmd [[
      nmap *   <Plug>(asterisk-z*)
      map #   <Plug>(asterisk-z#)
      map g*  <Plug>(asterisk-gz*)
      map g#  <Plug>(asterisk-gz#)
      map z*  <Plug>(asterisk-*)
      map gz* <Plug>(asterisk-z*)
      map z#  <Plug>(asterisk-#)
      map gz# <Plug>(asterisk-z#)
      let g:asterisk#keeppos = 1
    ]]
      end,
    },
    {
      'hedyhli/outline.nvim',
      config = function()
        vim.keymap.set('n', '<leader>fo', '<cmd>Outline<CR>', { desc = 'Toggle Outline' })

        require('outline').setup {}
      end,
    },
    { 'romainl/vim-cool' },
    {
      'wintermute-cell/gitignore.nvim',
      config = function()
        require 'gitignore'
      end,
    },
    {
      'Aasim-A/scrollEOF.nvim',
      event = { 'CursorMoved', 'WinScrolled' },
      opts = {},
    },
    {
      'kevinhwang91/nvim-bqf',
      ft = 'qf',
      opts = { preview = { auto_preview = false } },
    },
    {
      'folke/which-key.nvim',
      event = 'VeryLazy',
      opts = {
        preset = 'helix',
        delay = 300,
        spec = {
          { '<leader>c', group = 'code' },
          { '<leader>f', group = 'file/find' },
          { '<leader>g', group = 'git' },
          { '<leader>h', group = 'hunk' },
          { '<leader>o', group = 'harpoon/swap' },
          { '<leader>r', group = 'run' },
          { '<leader>s', group = 'search/symbol' },
          { '<leader>u', group = 'toggle' },
          { '<leader>x', group = 'file ops' },
          { '<leader>y', group = 'yank path' },
          { '<leader>z', group = 'zen' },
        },
      },
    },
    {
      'folke/trouble.nvim',
      cmd = { 'Trouble' },
      keys = {
        { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
        { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
        { '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols (Trouble)' },
        { '<leader>xl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP Definitions / references (Trouble)' },
        { '<leader>xL', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List (Trouble)' },
        { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List (Trouble)' },
      },
      opts = {},
    },
    {
      'linrongbin16/lsp-progress.nvim',
      config = function()
        require('lsp-progress').setup {
          format = function(client_messages)
            local lsp_icon = ''
            local clients = vim.lsp.get_clients { bufnr = 0 }
            if #clients == 0 then
              return ''
            end
            if #client_messages > 0 then
              return lsp_icon .. ' ' .. table.concat(client_messages, ' ')
            end
            return '󰄬'
          end,
          client_format = function(_, spinner, series_messages)
            if #series_messages > 0 then
              return spinner
            end
            return nil
          end,
        }
        local lsp_progress_augroup = vim.api.nvim_create_augroup('UserLspProgressStatus', { clear = true })
        vim.api.nvim_create_autocmd('User', {
          group = lsp_progress_augroup,
          pattern = 'LspProgressStatusUpdated',
          callback = require('lualine').refresh,
        })
      end,
    },

    -- 7. UTILITIES
    {
      'mbbill/undotree',
      cmd = 'UndotreeToggle',
      keys = { { '<Leader>fu', '<cmd>UndotreeToggle<CR>', desc = 'Undotree', silent = true } },
    },

    -- 8. WORK
    {
      'https://gitlab.com/schrieveslaach/sonarlint.nvim',
      name = 'sonarlint.nvim',
      lazy = true,
      init = function()
        vim.api.nvim_create_user_command('SonarlintEnable', function()
          require('lazy').load { plugins = { 'sonarlint.nvim' } }
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == 'python' then
              vim.api.nvim_exec_autocmds('FileType', { buffer = buf })
            end
          end
        end, { desc = 'Enable SonarLint for Python buffers' })
      end,
      opts = {
        server = {
          cmd = {
            'sonarlint-ls',
            '-stdio',
            '-analyzers',
            vim.fn.expand '$HOME/.rice/files/misc/sonarpython.jar',
          },
          settings = {
            sonarlint = {
              connectedMode = {
                connections = {
                  sonarqube = {
                    {
                      connectionId = 'gdp-admin',
                      serverUrl = 'https://sonarcloud.io',
                      disableNotifications = false,
                    },
                    -- {
                    --   connectionId = 'sqa-obrol',
                    --   serverUrl = 'https://sqa.obrol.id',
                    --   disableNotifications = false,
                    -- },
                  },
                  sonarcloud = {
                    {
                      connectionId = 'gdp-admin',
                      serverUrl = 'https://sonarcloud.io',
                      region = 'US',
                      organizationKey = 'gdp-admin',
                      disableNotifications = false,
                    },
                  },
                },
              },
            },
          },

          before_init = function(params, config)
            local project_root_and_ids = {
              ['/home/agung-b-sorlawan/Documents/services-llm-service'] = 'nlp',
              ['/home/agung-b-sorlawan/Documents/gen-ai-internal/libs/gllm-core'] = 'gllm-core',
              ['/home/agung-b-sorlawan/Documents/gen-ai-internal/libs/gllm-privacy'] = 'gllm-core',
              ['/home/agung-b-sorlawan/Documents/gen-ai-internal/libs/gllm-evals'] = 'gllm-evals',
            }

            config.settings.sonarlint.connectedMode.project = {
              -- connectionId = 'sqa-obrol',
              connectionId = 'gdp-admin',
              projectKey = project_root_and_ids[params.rootPath],
            }
          end,
        },
        filetypes = {
          'python',
        },
      },
    },
  }, { ui = { border = 'rounded' } })
  vim.g.__user_lazy_setup_done = true
end

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

  vim.cmd 'redrawstatus'
  vim.notify('Config reloaded' .. (target ~= '' and (' -> ' .. target) or ''), vim.log.levels.INFO)
end, { force = true })

vim.cmd 'silent! cunabbrev ec'
vim.cmd 'silent! cunabbrev rr'
vim.cmd [[cnoreabbrev <expr> ec getcmdtype() == ':' && getcmdline() == 'ec' ? 'Ec' : 'ec']]
vim.cmd [[cnoreabbrev <expr> rr getcmdtype() == ':' && getcmdline() == 'rr' ? 'Rr' : 'rr']]

if vim.g.monochrome_mode == 'dark' then
  set_random_colorscheme 'lake-dweller'
else
  set_random_colorscheme 'koda-glade'
end
