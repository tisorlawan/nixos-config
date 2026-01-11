-- ============================================================================
-- LAZY.NVIM BOOTSTRAP
-- ============================================================================

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath }
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- APPEARANCE
-- ============================================================================

vim.cmd 'syntax on'

-- ============================================================================
-- OPTIONS
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

-- Leader
vim.g.mapleader = ' '

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
vim.opt.wildmenu = true
vim.opt.wildmode = 'longest:full,full'
vim.opt.showcmd = true
vim.opt.cursorline = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Files
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand '~/.vim/undodir'

-- Performance
vim.opt.lazyredraw = true
vim.opt.updatetime = 300
vim.opt.timeout = true
vim.opt.ttimeoutlen = 0

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- UI
vim.opt.showmatch = true
vim.opt.ruler = true
vim.opt.laststatus = 2
vim.opt.shortmess:remove 'S'
vim.opt.encoding = 'utf-8'
vim.opt.title = true

-- Path & Wildignore
vim.opt.path = '.,**'
vim.opt.wildignore:append '**/node_modules/**,**/.git/**,**/dist/**,**/build/**,**/__pycache__/**,*.pyc,*.o,*.obj,*.h'

-- ============================================================================
-- KEYMAPS - GENERAL
-- ============================================================================

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

local terminal_buf = nil

map('n', '<leader>w', '<cmd>update<CR>', opts)
map('n', '<leader>h', '<cmd>nohlsearch<CR>', opts)
map('n', '<leader>q', '<cmd>q<CR>', opts)

-- ============================================================================
-- BUFFER MANAGEMENT
-- ============================================================================

local function bufdelete(force)
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].modified and not force then
    print 'Buffer has unsaved changes. Use <leader>D to force delete.'
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
  pcall(vim.api.nvim_buf_delete, buf, { force = force })
end

map('n', '<leader>d', function()
  bufdelete(false)
end, opts)
map('n', '<leader>D', function()
  bufdelete(true)
end, opts)

-- ============================================================================
-- KEYMAPS - PATH/FILE UTILS
-- ============================================================================

map('n', '<leader>yp', function()
  local path = vim.fn.expand '%:.'
  vim.fn.setreg('+', path)
  print('Copied: ' .. path)
end, opts)

map('n', '<leader>yP', function()
  local path = vim.fn.expand '%:p'
  vim.fn.setreg('+', path)
  print('Copied: ' .. path)
end, opts)

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
end, opts)

map('n', '<leader>xc', function()
  local file = vim.fn.expand '%:p'
  if file == '' then
    return
  end
  vim.fn.system('chmod +x ' .. vim.fn.shellescape(file))
  print('Made executable: ' .. file)
end, { desc = 'Chmod +x current file' })

-- ============================================================================
-- KEYMAPS - NAVIGATION
-- ============================================================================

-- Buffer navigation
map('n', '<leader><Tab>', '<C-^>', opts)
map('n', '<leader>j', '<cmd>bnext<CR>', opts)
map('n', '<leader>k', '<cmd>bprev<CR>', opts)

-- Mark navigation (swap ' and `)
map('n', "'", '`', opts)
map('n', '`', "'", opts)

-- Insert mode navigation
map('i', '<C-h>', '<Left>', opts)
map('i', '<C-j>', '<Down>', opts)
map('i', '<C-k>', '<Up>', opts)
map('i', '<C-l>', '<Right>', opts)

-- ============================================================================
-- KEYMAPS - TERMINAL
-- ============================================================================

map('t', '<C-w>', '<C-w>', { noremap = true })
map('t', '<C-u>', '<C-u>', { noremap = true })
map('t', '<C-a>', '<C-a>', { noremap = true })
map('t', '<C-e>', '<C-e>', { noremap = true })
map('t', '<C-k>', '<C-k>', { noremap = true })

-- ============================================================================
-- AUTOCMDS
-- ============================================================================

-- Restore cursor position
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 1 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank { timeout = 150 }
  end,
})

-- ============================================================================
-- QUICKFIX
-- ============================================================================

map('n', 'cn', '<cmd>cnext<CR>', opts)
map('n', 'cp', '<cmd>cprev<CR>', opts)
map('n', 'co', '<cmd>copen<CR>', opts)

-- ============================================================================
-- NETRW
-- ============================================================================

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25
vim.g.netrw_altv = 1

-- ============================================================================
-- CLOSE DIAGNOSTICS/SPECIAL WINDOWS
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
-- TERMINAL RUNNER
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
  vim.fn.termopen(cmd, {
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
  local cur_win = vim.api.nvim_get_current_win()
  open_terminal_with_cmd(cmd)
  vim.api.nvim_set_current_win(cur_win)
end

local function edit_and_run_in_terminal()
  local cmd = vim.fn.input('$ ', last_shell_cmd)
  if cmd ~= '' then
    last_shell_cmd = cmd
    open_terminal_with_cmd(cmd)
  end
end

map('n', '<leader><leader>', edit_and_run_in_terminal, opts)
map('n', '<leader>rr', run_in_terminal, opts)
map('n', '<leader>re', edit_and_run_in_terminal, opts)
map('n', '<leader>rx', clear_last_shell_command, opts)

-- ============================================================================
-- FUZZY FINDER (fzf/fzy)
-- ============================================================================

local fzf_tempfile = vim.fn.tempname()
local fzf_source_win = 0

local function get_fuzzy_finder()
  if vim.fn.executable 'fzf' == 1 then
    return 'fzf'
  elseif vim.fn.executable 'fzy' == 1 then
    return 'fzy'
  end
  return ''
end

local function get_file_lister(exclude_file)
  local exclude = ''
  if exclude_file ~= '' then
    exclude = ' | grep -vF ' .. vim.fn.shellescape(exclude_file)
  end
  if vim.fn.executable 'fd' == 1 then
    return 'fd -t f' .. exclude
  elseif vim.fn.isdirectory '.git' == 1 then
    return 'git ls-files' .. exclude
  else
    return "find . -type f | sed 's#^\\./##'" .. exclude
  end
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
  vim.fn.termopen({ 'sh', '-c', cmd }, {
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

local function fzf_callback_with_mode(lines)
  if #lines < 2 then
    return
  end

  local key = lines[1]

  if key == 'ctrl-q' then
    vim.fn.win_gotoid(fzf_source_win)
    local qf_items = {}
    for i = 2, #lines do
      if lines[i] ~= '' then
        table.insert(qf_items, { filename = lines[i], lnum = 1 })
      end
    end
    if #qf_items > 0 then
      vim.fn.setqflist({}, 'r', { title = 'Files', items = qf_items })
      vim.cmd 'copen'
    end
    return
  end

  if vim.fn.win_gotoid(fzf_source_win) ~= 1 then
    return
  end

  for i = 2, #lines do
    local file = lines[i]
    if file ~= '' and vim.fn.filereadable(file) == 1 then
      if i == 2 then
        if key == 'ctrl-s' then
          vim.cmd('split ' .. vim.fn.fnameescape(file))
        elseif key == 'ctrl-v' then
          vim.cmd('vsplit ' .. vim.fn.fnameescape(file))
        else
          vim.cmd('edit ' .. vim.fn.fnameescape(file))
        end
      else
        vim.cmd('badd ' .. vim.fn.fnameescape(file))
      end
    end
  end
end

local function fzf_callback(lines)
  if #lines > 0 and lines[1] ~= '' and vim.fn.filereadable(lines[1]) == 1 then
    if vim.fn.win_gotoid(fzf_source_win) == 1 then
      vim.cmd('edit ' .. vim.fn.fnameescape(lines[1]))
    end
  end
end

local function file_picker()
  fzf_source_win = vim.api.nvim_get_current_win()
  local finder = get_fuzzy_finder()
  if finder ~= '' then
    fzf_tempfile = vim.fn.tempname()
    local current_file = vim.fn.expand '%:.'
    local lister = get_file_lister(current_file)

    local cmd
    if finder == 'fzy' then
      cmd = lister .. ' | ' .. finder .. ' > ' .. fzf_tempfile
    else
      cmd = lister .. ' | ' .. finder .. ' --layout=reverse --multi --expect=ctrl-s,ctrl-v,ctrl-q > ' .. fzf_tempfile
    end

    open_picker_terminal(cmd, '[Files]', function()
      if vim.fn.filereadable(fzf_tempfile) == 1 then
        local lines = vim.fn.readfile(fzf_tempfile)
        vim.fn.delete(fzf_tempfile)
        if finder == 'fzy' then
          fzf_callback(lines)
        else
          fzf_callback_with_mode(lines)
        end
      end
    end)
  else
    vim.api.nvim_feedkeys(':find *', 'n', false)
  end
end

local function buffer_picker()
  fzf_source_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()
  local finder = get_fuzzy_finder()

  if finder ~= '' then
    fzf_tempfile = vim.fn.tempname()
    local bufs = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].buflisted and buf ~= current_buf and vim.bo[buf].buftype ~= 'terminal' then
        local name = vim.api.nvim_buf_get_name(buf)
        if name ~= '' then
          local cwd = vim.fn.getcwd()
          if name:sub(1, #cwd) == cwd then
            name = name:sub(#cwd + 2)
          end
          table.insert(bufs, name)
        end
      end
    end

    if #bufs == 0 then
      print 'No other buffers'
      return
    end

    local cmd
    if finder == 'fzy' then
      local buflist = table.concat(bufs, '\n')
      cmd = 'echo ' .. vim.fn.shellescape(buflist) .. ' | ' .. finder .. ' > ' .. fzf_tempfile
    else
      local buflist = table.concat(bufs, '\n')
      cmd = 'echo ' .. vim.fn.shellescape(buflist) .. ' | ' .. finder .. ' --layout=reverse --multi --expect=ctrl-s,ctrl-v,ctrl-q > ' .. fzf_tempfile
    end

    open_picker_terminal(cmd, '[Buffers]', function()
      if vim.fn.filereadable(fzf_tempfile) == 1 then
        local lines = vim.fn.readfile(fzf_tempfile)
        vim.fn.delete(fzf_tempfile)
        if finder == 'fzy' then
          fzf_callback(lines)
        else
          fzf_callback_with_mode(lines)
        end
      end
    end)
  else
    vim.cmd 'ls'
    vim.api.nvim_feedkeys(':buffer ', 'n', false)
  end
end

map('n', '<C-n>', buffer_picker, opts)

-- ============================================================================
-- GREP (ripgrep/grep)
-- ============================================================================

local function grep_picker(query)
  local parts = vim.split(query, ' -g ')
  local search_term = parts[1]
  local additional_flags = ''

  if #parts > 1 then
    for i = 2, #parts do
      additional_flags = additional_flags .. ' -g ' .. parts[i]
    end
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

    if file and line then
      vim.cmd('edit ' .. vim.fn.fnameescape(file))
      vim.api.nvim_win_set_cursor(0, { tonumber(line), tonumber(col) - 1 })
      vim.cmd 'normal! zz'
      print 'No other match'
    end
    return
  end

  vim.fn.setqflist({}, 'r', {
    title = 'Grep: ' .. query,
    lines = output,
    efm = '%f:%l:%c:%m,%f:%l:%m',
  })

  vim.cmd 'copen'
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
end, opts)

map('n', '<leader>l', function()
  local query = vim.fn.input 'Grep: '
  if query ~= '' then
    grep_picker(query)
  end
end, opts)

map('n', '<leader>sl', '<cmd>Lazy<cr>', { desc = 'Lazy' })
map('n', '<leader>sc', '<cmd>ConformInfo<cr>', { desc = 'Conform Info' })
map('n', '<leader>si', '<cmd>LspInfo<cr>', { desc = 'LSP Info' })
map('n', '<leader>sm', '<cmd>Mason<cr>', { desc = 'Mason' })

vim.api.nvim_create_user_command('Grep', function(cmd_opts)
  grep_picker(cmd_opts.args)
end, { nargs = 1 })

-- ============================================================================
-- HARPOON (file bookmarks)
-- ============================================================================

local harpoon_files = {}
local harpoon_dir = vim.fn.expand '~/.vim/harpoon'

local function harpoon_get_file()
  local cwd = vim.fn.getcwd()
  local hash = vim.fn.sha256(cwd):sub(1, 16)
  if vim.fn.isdirectory(harpoon_dir) == 0 then
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

map('n', '<leader>ha', harpoon_add, opts)
map('n', '<leader>hr', harpoon_remove, opts)
map('n', '<leader>he', harpoon_edit, opts)
map('n', '<leader>hm', harpoon_menu, opts)
map('n', '<M-1>', function()
  harpoon_go(1)
end, opts)
map('n', '<M-2>', function()
  harpoon_go(2)
end, opts)
map('n', '<M-3>', function()
  harpoon_go(3)
end, opts)
map('n', '<M-4>', function()
  harpoon_go(4)
end, opts)
map('n', '<M-5>', function()
  harpoon_go(5)
end, opts)
map('n', '<Esc>1', function()
  harpoon_go(1)
end, opts)
map('n', '<Esc>2', function()
  harpoon_go(2)
end, opts)
map('n', '<Esc>3', function()
  harpoon_go(3)
end, opts)
map('n', '<Esc>4', function()
  harpoon_go(4)
end, opts)
map('n', '<Esc>5', function()
  harpoon_go(5)
end, opts)

-- ============================================================================
-- SEMICOLON INSERT (C-d)
-- ============================================================================

local semicolon_filetypes = { 'c', 'cpp', 'rust', 'java', 'javascript', 'typescript', 'css', 'php', 'go' }

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
end, { expr = true })

-- ============================================================================
-- UI & ICONS
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
  local fg = hl and hl.fg or hl.foreground
  return fg and { fg = string.format('#%06x', fg) } or nil
end

local function apply_transparency()
  local groups = {
    'NormalFloat',
    'FloatBorder',
    'FloatTitle',
    'DiagnosticFloatingError',
    'DiagnosticFloatingWarn',
    'DiagnosticFloatingInfo',
    'DiagnosticFloatingHint',
    'BlinkCmpMenu',
    'BlinkCmpMenuBorder',
    'Pmenu',
    'BlinkCmpDoc',
    'BlinkCmpDocBorder',
    'BlinkCmpLabel',
    'BlinkCmpKind',
    'BlinkCmpLabelDescription',
    'BlinkCmpLabelDetail',
    'BlinkCmpSource',
  }
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = 'none', ctermbg = 'none' })
  end

  -- vim.api.nvim_set_hl(0, 'PmenuSel', { bg = '#2D4F67', fg = 'none' })
  -- vim.api.nvim_set_hl(0, 'BlinkCmpMenuSelection', { bg = '#2D4F67', fg = 'none' })
end

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = apply_transparency,
})

-- ============================================================================
-- USED FILETYPES SYSTEM
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
    c = { formatters = { 'clang_format' }, servers = { 'clangd' } },
    go = { formatters = { 'gofumpt', 'goimports', 'golines' }, servers = { 'gopls' } },
    html = { servers = { 'html' }, formatters = { 'biome' }, linters = { 'htmlhint' } },
    javascript = { formatters = { 'biome' } },
    json = { formatters = { 'biome' }, linters = { 'jsonlint' } },
    lua = { formatters = { 'stylua' }, servers = { 'lua_ls' } },
    markdown = { linters = { 'markdownlint' }, formatters = { 'prettierd' }, servers = { 'marksman' } },
    nix = { servers = { 'nil_ls' }, formatters = { 'nixpkgs_fmt' } },
    php = { formatters = { 'php_cs_fixer' }, servers = { 'phpactor', 'html' } },
    python = { formatters = { 'ruff_format', 'ruff_organize_imports' }, servers = { 'basedpyright', 'ruff' } },
    rust = { servers = { 'rust_analyzer' }, formatters = { 'rustfmt' } },
    sh = { servers = { 'bashls' }, formatters = { 'shfmt' } },
    typescript = { formatters = { 'biome-check' }, servers = { 'ts_ls', 'eslint' } },
    typescriptreact = { formatters = { 'biome-check' }, servers = { 'ts_ls', 'eslint' } },
    zig = { formatters = { 'zigfmt' }, servers = { 'zls' } },
  }

  local formatters_by_ft = {}
  local linters_by_ft = {}
  for _, ft in ipairs(fts) do
    if config[ft] then
      if config[ft].formatters then
        formatters_by_ft[ft] = config[ft].formatters
      end
      if config[ft].linters then
        linters_by_ft[ft] = config[ft].linters
      end
    end
  end

  return { used_ft = fts, config = config, formatters_by_ft = formatters_by_ft, linters_by_ft = linters_by_ft }
end

local used_ft_sys = get_used_ft()

-- ============================================================================
-- LSP
-- ============================================================================

vim.opt.signcolumn = 'yes:1'

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })

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
    vim.diagnostic.goto_prev { float = { border = 'rounded' } }
  end, 'Prev Diagnostic')
  lmap(']d', function()
    vim.diagnostic.goto_next { float = { border = 'rounded' } }
  end, 'Next Diagnostic')
  lmap('<leader>cd', function()
    vim.diagnostic.open_float { border = 'rounded' }
  end, 'Line Diagnostics')
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
      source = 'always',
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  }
end

setup_diagnostic()

-- ============================================================================
-- @PLUGINS (lazy.nvim)
-- ============================================================================

require('lazy').setup({
  -- 1. COLORSCHEME
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    config = function()
      require('kanagawa').setup { transparent = true }
      vim.cmd 'colorscheme kanagawa'
    end,
  },

  -- 2. CORE ENGINE
  {
    'nvim-treesitter/nvim-treesitter',
    main = 'nvim-treesitter.configs',
    branch = 'master',
    build = ':TSUpdate',
    dependencies = {
      { 'yioneko/nvim-yati', event = { 'BufReadPost', 'BufNewFile' } },
      { 'nvim-treesitter/playground' },
      { 'windwp/nvim-ts-autotag' },
    },
    lazy = false,
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'python', 'vim', 'vimdoc' },
      auto_install = true,
      ignore_install = { 'gitcommit' },
      highlight = { enable = true, additional_vim_regex_highlighting = { 'ruby', 'elixir' } },
      indent = { enable = true, disable = { 'python', 'css', 'rust', 'lua', 'javascript', 'tsx', 'typescript', 'toml', 'json', 'c', 'heex' } },
      yati = { enable = true, disable = { 'rust' }, default_lazy = true, default_fallback = 'auto' },
    },
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          on_attach(vim.lsp.get_client_by_id(event.data.client_id), event.buf)
        end,
      })

      local mason_lsp = {}
      for _, ft in ipairs(used_ft_sys.used_ft) do
        for _, server in ipairs((used_ft_sys.config[ft] or {}).servers or {}) do
          table.insert(mason_lsp, server)
        end
      end

      local formatters_to_mason = {
        clang_format = 'clang-format',
        ruff_fix = 'ruff',
        ruff_format = 'ruff',
        ruff_organize_imports = 'ruff',
        nixpkgs_fmt = 'nixpkgs-fmt',
        php_cs_fixer = 'php-cs-fixer',
        ['biome-check'] = 'biome',
      }

      local tools = {}
      for _, names in pairs(used_ft_sys.formatters_by_ft) do
        for _, name in ipairs(names) do
          table.insert(tools, formatters_to_mason[name] or name)
        end
      end
      for _, names in pairs(used_ft_sys.linters_by_ft) do
        for _, name in ipairs(names) do
          table.insert(tools, name)
        end
      end

      require('mason-tool-installer').setup { ensure_installed = tools }

      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local handlers = {
        ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
        ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' }),
      }

      local server_configs = {
        pyright = {
          settings = {
            python = {
              analysis = {
                autoImportCompletions = false,
                autoSearchPaths = false,
                useLibraryCodeForTypes = false,
                diagnosticMode = 'openFilesOnly',
                stubPath = '~/.typings',
              },
            },
          },
        },
        html = { filetypes = { 'html', 'php' } },
      }

      for _, server in ipairs(mason_lsp) do
        local cfg = vim.tbl_deep_extend('force', { capabilities = capabilities, handlers = handlers }, server_configs[server] or {})
        if vim.lsp.config then
          vim.lsp.config(server, cfg)
          vim.lsp.enable(server)
        else
          require('lspconfig')[server].setup(cfg)
        end
      end
    end,
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = used_ft_sys.formatters_by_ft,
      formatters = {
        biome = {
          args = {
            'format',
            '--javascript-formatter-indent-width=2',
            '--indent-style=space',
            '--json-formatter-indent-style=space',
            '--json-formatter-indent-width=4',
            '--write',
            '--stdin-file-path',
            '$FILENAME',
          },
        },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    },
    config = function(_, opts)
      require('conform').setup(opts)
      vim.api.nvim_create_user_command('ToggleAutoFormat', function()
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        print((vim.b.disable_autoformat and '-disabled-' or '-enabled-') .. ' auto format')
      end, {})
      vim.keymap.set('n', '<leader>uf', '<cmd>ToggleAutoFormat<cr>', { desc = 'toggle autoformat' })
      vim.keymap.set('n', '<leader>ua', function()
        vim.g.disable_autocomplete = not vim.g.disable_autocomplete
        print((vim.g.disable_autocomplete and '-disabled-' or '-enabled-') .. ' autocomplete')
      end, { desc = 'toggle autocomplete' })
    end,
  },
  {
    'mfussenegger/nvim-lint',
    event = 'VeryLazy',
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = used_ft_sys.linters_by_ft
      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function()
          lint.try_lint()
        end,
      })
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
          auto_show = function(ctx)
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
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
    },
  },

  -- 4. NAVIGATION & PICKERS
  {
    'ibhagwan/fzf-lua',
    event = { 'BufReadPre', 'BufNewFile', 'VimEnter' },
    -- stylua: ignore
    keys = {
      { '<leader>fF', function() require('fzf-lua').files { cwd = vim.fn.getcwd() } end, desc = 'Find Files (cwd)' },
      { '<leader>fg', function() require('fzf-lua').git_files() end, desc = 'Find Files (git-files)' },
      { '<leader>fr', function() require('fzf-lua').oldfiles() end, desc = 'Recent' },
      { '<leader>fR', function() require('fzf-lua').oldfiles { cwd = vim.fn.getcwd() } end, desc = 'Recent (cwd)' },
      { '<leader>gc', function() require('fzf-lua').git_commits() end, desc = 'Commits' },
      { '<leader>gs', function() require('fzf-lua').git_status() end, desc = 'Status' },
      { '<leader>fy', function() require('fzf-lua').registers() end, desc = 'Registers' },
      { '<leader>fx', function() require('fzf-lua').diagnostics_document() end, desc = 'Document Diagnostics' },
      { '<leader>fX', function() require('fzf-lua').diagnostics_workspace() end, desc = 'Workspace Diagnostics' },
      { '<leader>sg', function() require('fzf-lua').grep_project() end, desc = 'Grep (Root Dir)' },
      { '<leader>fM', function() require('fzf-lua').man_pages() end, desc = 'Man Pages' },
      { '<leader>f.', function() require('fzf-lua').resume() end, desc = 'Resume' },
      { '<leader>ss', function() require('fzf-lua').lsp_document_symbols() end, desc = 'Goto Symbol' },
      { '<leader>S', function() require('fzf-lua').lsp_workspace_symbols() end, desc = 'Goto Symbol (Workspace)' },
      { '<leader>uC', function() require('fzf-lua').colorschemes() end, desc = 'Colorscheme with Preview' },
      { '<leader>cs', function() require('fzf-lua').lsp_document_symbols() end, desc = 'Document symbols' },
      { '<leader>cw', function() require('fzf-lua').lsp_live_workspace_symbols() end, desc = 'Workspace symbols' },
      { '<leader>ca', function() require('fzf-lua').lsp_code_actions() end, desc = 'Code actions' },
      { '<leader>fd', function() require('fzf-lua').fzf_exec('fd -u --type d -E .cache -E snap -E cache -E go -E .git -E .npm -E .miniconda3 -E .conda -E __pycache__ -E .docker -E .cargo -E .cert -E .windsurf -E .minikube -E .ghcup -E .claude -E .stack -E .cabal -E .aws -E tmp -E .rustup -E uv -E .local/share -E .codeium -E .cargo_build_artifacts -E .ipython -E .ruff_cache -E .venv -E Slack -E node_modules -E .jupyter -E nltk_data -E .local/state -E .zoom', { prompt = '~/', cwd = '~', actions = { ['default'] = function(selected) if selected and #selected > 0 then local root = vim.fn.expand '~' .. '/' vim.cmd('cd ' .. root .. selected[1]) require('fzf-lua').files() end end } }) end, desc = 'Fuzzy cd to dir under ~' },
    },
    config = function()
      local actions = require 'fzf-lua.actions'
      vim.cmd [[FzfLua register_ui_select]]
      require('fzf-lua').setup {
        winopts = { preview = { delay = 0 } },
        manpages = { previewer = 'man_native' },
        helptags = { previewer = 'help_native' },
        lsp = { code_actions = { previewer = 'codeaction_native' } },
        files = {
          fd_opts = [[--color never --type f --hidden --follow --strip-cwd-prefix -E .git -E .jj -E node_modules -E .venv -E .sqlx -E resource_snapshots ]],
        },
        grep = {
          rg_opts = '--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e',
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
    keys = { {
      '<c-p>',
      function()
        require('fff').find_files()
      end,
      desc = 'Open file picker',
    } },
  },
  {
    'justinmk/vim-dirvish',
    event = 'VeryLazy',
    dependencies = { 'roginfarrer/vim-dirvish-dovish' },
    lazy = false,
    enabled = true,
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
      return {
        close_if_last_window = true,
        enable_git_status = true,
        window = { mappings = { ['Y'] = copy_path } },
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
    enabled = true,
    lazy = true,
    -- stylua: ignore
    keys = {
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, { silent = true } },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, { silent = true } },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, { silent = true } },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, { silent = true } },
      { "<C-left>", function() require("smart-splits").resize_left() end, { silent = true } },
      { "<C-right>", function() require("smart-splits").resize_right() end, { silent = true } },
      { "<C-up>", function() require("smart-splits").resize_up() end, { silent = true } },
      { "<C-down>", function() require("smart-splits").resize_down() end, { silent = true } },
      { "<leader>oh", function() require("smart-splits").swap_buf_left() end, { silent = true }, desc = "Swap Left" },
      { "<leader>oj", function() require("smart-splits").swap_buf_down() end, { silent = true }, desc = "Swap Down" },
      { "<leader>ok", function() require("smart-splits").swap_buf_up() end, { silent = true }, desc = "Swap Up" },
      { "<leader>ol", function() require("smart-splits").swap_buf_right() end, { silent = true }, desc = "Swap Right" },
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
    opts = { safe_labels = 'tyuofghjklvbn', labels = 'sfnjklhowembuyvrgtqpcxz/SFNJKLHOWEIMBUYVRGTAQPCXZ' },
    dependencies = { 'tpope/vim-repeat' },
  },

  -- 5. UI COMPONENTS
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'bwpge/lualine-pretty-path' },
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
            { 'pretty_path' },
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
          lualine_x = { { 'diff', symbols = { added = ui.icons.git.added, modified = ui.icons.git.modified, removed = ui.icons.git.removed } } },
          lualine_y = { { 'progress', separator = ' ', padding = { left = 1, right = 0 } }, { 'location', padding = { left = 0, right = 1 } } },
          lualine_z = {
            function()
              return ' ' .. os.date '%R'
            end,
          },
        },
        inactive_sections = { lualine_c = { 'pretty_path' } },
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
        lmap("n", "]h", function() if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end end, "Next Hunk")
        lmap("n", "[h", function() if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end end, "Prev Hunk")
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
      end,
    },
  },
  {
    'f-person/git-blame.nvim',
    event = 'VeryLazy',
    enabled = true,
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
    opts = { enabled = false, message_template = ' <summary> • <date> • <author> • <<sha>>', date_format = '%d-%m-%Y %H:%M:%S', virtual_text_column = 1 },
  },
  {
    'cdmill/focus.nvim',
    cmd = { 'Focus', 'Zen', 'Narrow' },
    keys = { { '<leader>zz', '<CMD>Zen<CR>', desc = 'Zen' } },
    opts = { zen = { opts = { statuscolumn = ' ' } } },
  },

  -- 6. PRODUCTIVITY & EDITING
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup { disable_filetype = { 'TelescopePrompt', 'spectre_panel', 'scheme' } }
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
  { 'romainl/vim-cool' },

  -- 7. UTILITIES
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    dependencies = {
      'AstroNvim/astrocore',
      opts = { mappings = { n = { ['<Leader>fu'] = { '<cmd>UndotreeToggle<CR>', desc = 'Find undotree' } } } },
    },
  },
  {
    'https://git.sr.ht/~swaits/zellij-nav.nvim',
    lazy = true,
    event = 'VeryLazy',
    enabled = false,
    keys = {
      { '<c-h>', '<cmd>ZellijNavigateLeftTab<cr>', { silent = true, desc = 'navigate left or tab' } },
      { '<c-j>', '<cmd>ZellijNavigateDown<cr>', { silent = true, desc = 'navigate down' } },
      { '<c-k>', '<cmd>ZellijNavigateUp<cr>', { silent = true, desc = 'navigate up' } },
      { '<c-l>', '<cmd>ZellijNavigateRightTab<cr>', { silent = true, desc = 'navigate right or tab' } },
    },
    opts = {},
  },

  -- 8. WORK
  {
    'https://gitlab.com/schrieveslaach/sonarlint.nvim',
    opts = {
      server = {
        cmd = {
          'sonarlint-ls',
          '-stdio',
          '-analyzers',
          vim.fn.expand '$MASON/share/sonarlint-analyzers/sonarpython.jar',
        },
        settings = {
          sonarlint = {
            connectedMode = {
              connections = {
                sonarqube = {
                  {
                    connectionId = 'sqa-obrol',
                    serverUrl = 'https://sqa.obrol.id',
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
          }

          config.settings.sonarlint.connectedMode.project = {
            connectionId = 'sqa-obrol',
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

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = 'rounded',
  max_width = 80,
  max_height = 20,
  stylize_markdown = true,
})

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = 'rounded',
  max_width = 80,
})
