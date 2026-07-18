local map = vim.keymap.set

vim.pack.add { 'https://github.com/akinsho/toggleterm.nvim' }

local toggleterm = require 'toggleterm'
local terms = require 'toggleterm.terminal'

toggleterm.setup {
  shell = 'fish',
  size = function(term)
    if term.direction == 'horizontal' then
      return vim.o.lines * 0.3
    elseif term.direction == 'vertical' then
      return vim.o.columns * 0.4
    elseif term.direction == 'float' then
      return math.floor(vim.o.lines * 0.6)
    end
  end,
  float_opts = {
    border = 'single',
    width = math.floor(vim.o.columns * 0.9),
    height = math.floor(vim.o.lines * 0.85),
    winblend = 0,
  },
  auto_scroll = true,
  start_in_insert = true,
  persist_size = true,
  persist_mode = true,
}

local floaterm = terms.Terminal:new {
  direction = 'float',
  id = 1002,
  hidden = true,
}

map({ 'n', 't' }, '<A-t>', function()
  local all_terms = terms.get_all()
  for _, term in ipairs(all_terms) do
    if term and term:is_open() then
      term:persist_mode()
      term:close()
      return
    end
  end
  floaterm:toggle()
end, { desc = 'Toggle terminal (smart)' })

local function set_terminal_window_options()
  local buf = vim.api.nvim_get_current_buf()
  local bo = vim.bo[buf]
  if bo.buftype ~= 'terminal' and bo.filetype ~= 'toggleterm' then
    return
  end

  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.foldcolumn = '0'
  vim.opt_local.signcolumn = 'no'
end

vim.api.nvim_create_autocmd({ 'TermOpen', 'TermEnter', 'BufWinEnter' }, {
  pattern = 'term://*',
  callback = set_terminal_window_options,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'toggleterm',
  callback = set_terminal_window_options,
})

-- @config --

local last_shell_cmd = ''
local error_runner_id = 9001
local error_runner_marker = '__OPENCODE_EXIT__:'
local error_runner_output = ''

local function get_current_filename()
  return vim.fn.expand '%:.'
end

local function expand_cmd(cmd)
  local filename = get_current_filename()
  return cmd:gsub('%%', filename)
end

local filetypes_run = {
  rust = { cmd = 'cargo check', prompt = 'cargo run' },
  zig = { cmd = 'zig build', prompt = 'zig run' },
  go = { cmd = 'go build ./...', prompt = 'go run .' },
  python = { cmd = 'python3 %', prompt = 'python3 %' },
  javascript = { cmd = 'node %', prompt = 'node %' },
  typescript = { cmd = 'npx ts-node %', prompt = 'npx ts-node %' },
  ruby = { cmd = 'ruby %', prompt = 'ruby %' },
  php = { cmd = 'php %', prompt = 'php %' },
  c = { cmd = 'make', prompt = 'make' },
  cpp = { cmd = 'make', prompt = 'make' },
}

local function get_ft_cmd()
  local ft = vim.bo.filetype
  if filetypes_run[ft] then
    return filetypes_run[ft]
  end
  return nil
end

local function run_in_terminal(cmd, opts)
  opts = opts or {}
  local direction = opts.direction or 'vertical'
  local keep_focus = opts.keep_focus
  local count = opts.count or 1

  local term_cmd = string.format("TermExec cmd='%s' direction=%s count=%d", cmd, direction, count)

  if keep_focus then
    term_cmd = term_cmd .. ' --go-back'
  end

  vim.cmd(term_cmd)
end

local function resolve_command()
  local ft_data = get_ft_cmd()
  local cmd = last_shell_cmd

  if cmd == '' and ft_data then
    cmd = ft_data.cmd
  end

  if cmd == '' then
    vim.notify('No previous command to run', vim.log.levels.WARN)
    return nil
  end

  cmd = expand_cmd(cmd)
  last_shell_cmd = cmd
  return cmd
end

local function run_last_command(opts)
  local cmd = resolve_command()
  if not cmd then
    return
  end

  run_in_terminal(cmd, opts)
end

local function run_last_command_open_on_error(opts)
  opts = opts or {}

  local cmd = resolve_command()
  if not cmd then
    return
  end

  local terms = require 'toggleterm.terminal'
  local direction = opts.direction or 'vertical'
  local cwd = vim.fn.getcwd()
  local term = terms.get(error_runner_id, true)

  if not term then
    term = terms.Terminal:new {
      id = error_runner_id,
      cmd = 'sh',
      dir = cwd,
      direction = direction,
      hidden = true,
      close_on_exit = false,
      on_stdout = function(t, _, data)
        if not data then
          return
        end

        error_runner_output = error_runner_output .. table.concat(data, '\n')
        local exit_code = error_runner_output:match(error_runner_marker .. '(%d+)')
        if not exit_code then
          return
        end

        error_runner_output = ''
        vim.schedule(function()
          if tonumber(exit_code) == 0 then
            if t:is_open() then
              t:close()
            end
            return
          end

          if not t:is_open() then
            t:open(nil, direction)
          end
          t:scroll_bottom()
          t:set_mode 'n'
        end)
      end,
    }

    term:open(nil, direction)
    term:close()
  end

  term.dir = cwd
  error_runner_output = ''
  term:send({
    string.format('cd %s', vim.fn.shellescape(cwd)),
    'clear',
    cmd,
    string.format('printf \'%s%%s\\n\' "$?"', error_runner_marker),
  }, true)
end

local function prompt_and_run_command(opts)
  local ft_data = get_ft_cmd()
  local default = last_shell_cmd

  if default == '' and ft_data then
    default = ft_data.prompt
  end

  if default == '' then
    default = expand_cmd '%'
  else
    default = expand_cmd(default)
  end

  local cmd = vim.fn.input('$ ', default)
  if cmd == '' then
    return
  end

  cmd = expand_cmd(cmd)
  last_shell_cmd = cmd
  run_in_terminal(cmd, opts)
end

local function clear_last_command()
  last_shell_cmd = ''
  vim.notify('Cleared last command', vim.log.levels.INFO)
end

local function run_ft_default(opts)
  local ft_data = get_ft_cmd()
  if not ft_data then
    vim.notify('No default run command for: ' .. vim.bo.filetype, vim.log.levels.WARN)
    return
  end

  local cmd = expand_cmd(ft_data.cmd)
  last_shell_cmd = ft_data.cmd
  run_in_terminal(cmd, opts)
end

map('n', '<leader><leader>', function()
  prompt_and_run_command { keep_focus = true }
end, { desc = 'Run shell command (keep focus)' })

map('n', '<leader>rr', function()
  run_last_command { keep_focus = true }
end, { desc = 'Re-run last command' })

map('n', '<leader>re', function()
  prompt_and_run_command { keep_focus = false }
end, { desc = 'Run command (switch to terminal)' })

map('n', '<leader>rx', clear_last_command, { desc = 'Clear last command' })

map('n', '<leader>rt', function()
  run_ft_default { keep_focus = true }
end, { desc = 'Run filetype default command' })

map('n', '<leader>rft', function()
  prompt_and_run_command { direction = 'float' }
end, { desc = 'Run in floating terminal' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp', 'rust' },
  callback = function(args)
    map('n', '<leader>a', run_last_command_open_on_error, {
      buffer = args.buf,
      desc = 'Run last command, open terminal on failure',
    })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'toggleterm',
  callback = function()
    map('t', '<Esc><Esc>', '<C-\\><C-n>', { buffer = true })
    map('t', '<C-h>', '<Cmd>wincmd h<CR>', { buffer = true })
    map('t', '<C-j>', '<Cmd>wincmd j<CR>', { buffer = true })
    map('t', '<C-k>', '<Cmd>wincmd k<CR>', { buffer = true })
    map('t', '<C-l>', '<Cmd>wincmd l<CR>', { buffer = true })
  end,
})
