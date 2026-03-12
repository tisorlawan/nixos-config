local M = {}

local map = vim.keymap.set

local terminal_buf
local terminal_cmd = ''
local last_shell_cmd = ''

local function open_terminal_with_cmd(cmd)
  local need_split = true

  if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
    local term_win = vim.fn.bufwinid(terminal_buf)
    if term_win ~= -1 then
      vim.api.nvim_set_current_win(term_win)
      need_split = false
      vim.cmd.enew()
    end

    pcall(vim.api.nvim_buf_delete, terminal_buf, { force = true })
  end

  if need_split then
    vim.cmd.vsplit()
    vim.cmd.enew()
  end

  terminal_cmd = cmd
  vim.fn.jobstart(cmd, {
    term = true,
    on_exit = function(_, exit_code)
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
  map('t', '<Esc><Esc>', '<C-\\><C-n>', { buffer = terminal_buf })

  local win = vim.api.nvim_get_current_win()
  vim.wo[win].statusline = '%#StatusLine# !' .. cmd .. ' %='
end

local function clear_last_command()
  last_shell_cmd = ''
  if vim.bo.filetype == 'rust' then
    last_shell_cmd = 'cargo check'
    print 'Reset to default: cargo check'
  else
    print 'Cleared last command'
  end
end

local function run_last_command()
  local cmd = last_shell_cmd
  if cmd == '' then
    if vim.bo.filetype ~= 'rust' then
      print 'No previous command'
      return
    end

    cmd = 'cargo check'
    last_shell_cmd = cmd
  end

  local filename = vim.fn.expand '%:.'
  cmd = cmd:gsub('%%', filename)

  local current_win = vim.api.nvim_get_current_win()
  open_terminal_with_cmd(cmd)
  vim.api.nvim_set_current_win(current_win)
end

local function prompt_and_run_command()
  local filename = vim.fn.expand '%:.'
  local default_cmd = last_shell_cmd:gsub('%%', filename)
  local cmd = vim.fn.input('$ ', default_cmd)

  if cmd == '' then
    return
  end

  cmd = cmd:gsub('%%', filename)
  last_shell_cmd = cmd
  open_terminal_with_cmd(cmd)
end

function M.close_runner()
  if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
    pcall(vim.api.nvim_buf_delete, terminal_buf, { force = true })
    terminal_buf = nil
  end
end

function M.setup()
  map('n', '<leader><leader>', prompt_and_run_command, { desc = 'Run shell command' })
  map('n', '<leader>rr', run_last_command, { desc = 'Re-run last command' })
  map('n', '<leader>re', prompt_and_run_command, { desc = 'Edit and run command' })
  map('n', '<leader>rx', clear_last_command, { desc = 'Clear last command' })
end

return M
