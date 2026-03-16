local M = {}

local map = vim.keymap.set

local function grep_picker(query)
  local search_term = query
  local additional_flags = ''

  while true do
    local glob_start = search_term:match '.*() %-g [^ ]+$'
    if not glob_start then
      break
    end

    local glob_part = search_term:sub(glob_start + 4)
    additional_flags = ' -g ' .. vim.fn.shellescape(glob_part) .. additional_flags
    search_term = search_term:sub(1, glob_start - 1)
  end

  local mode_flags = ' --fixed-strings'
  local hidden_flags = ''
  local actual_term = search_term
  local prefix_match = search_term:match '^([riu]+):'

  if prefix_match then
    actual_term = search_term:sub(#prefix_match + 2)
    if prefix_match:find 'i' then
      mode_flags = mode_flags .. ' --ignore-case'
    end
    if prefix_match:find 'r' then
      mode_flags = mode_flags:gsub(' %-%-fixed%-strings', '')
    end
    if prefix_match:find 'u' then
      hidden_flags = ' -uu'
    end
  end

  local escaped_term = vim.fn.shellescape(actual_term)
  local cmd
  if vim.fn.executable 'rg' == 1 then
    cmd = 'rg --vimgrep --smart-case' .. hidden_flags .. mode_flags .. additional_flags .. ' -- ' .. escaped_term
  else
    cmd = 'grep -rnI ' .. escaped_term .. ' .'
  end

  local output = vim.fn.systemlist(cmd)
  if #output == 0 then
    print('No matches found for: ' .. query)
    return
  end

  if #output == 1 then
    local file, line, column = output[1]:match '([^:]+):(%d+):(%d+):'
    if not file then
      file, line = output[1]:match '([^:]+):(%d+):'
      column = 1
    end

    if file and line and vim.fn.filereadable(file) == 1 then
      local ok = pcall(vim.cmd, { cmd = 'drop', args = { file } })
      if not ok then
        vim.cmd.edit(vim.fn.fnameescape(file))
      end
      vim.api.nvim_win_set_cursor(0, { tonumber(line), tonumber(column) - 1 })
      vim.cmd.normal { 'zz', bang = true }
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

  vim.cmd.copen()
  vim.api.nvim_buf_set_name(0, ' ' .. actual_term .. ' [' .. #output .. ']')
  vim.cmd [[echo ""]]
end

local function get_visual_selection()
  vim.cmd [[noau normal! "vy]]
  local text = vim.fn.getreg 'v'
  vim.fn.setreg('v', {})
  return text
end

function _G.grep_operator(type)
  local save = vim.fn.getreg '"'
  local save_type = vim.fn.getregtype '"'

  if type == 'char' then
    vim.cmd [[noau normal! `[v`]y]]
  elseif type == 'line' then
    vim.cmd [[noau normal! '[V']y]]
  else
    return
  end

  local text = vim.fn.getreg('"'):gsub('\n', ' ')
  vim.fn.setreg('"', save, save_type)
  if text ~= '' then
    grep_picker(text)
  end
end

function M.setup()
  map('v', '<leader>l', function()
    local text = get_visual_selection()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)

    if text ~= '' then
      grep_picker(text:gsub('\n', ' '))
    end
  end, { desc = 'Grep selection' })

  map('v', '<leader>u', function()
    local text = get_visual_selection()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)

    if text ~= '' then
      grep_picker('uu:' .. text:gsub('\n', ' '))
    end
  end, { desc = 'Grep selection incl hidden' })

  map('v', '<leader>L', function()
    local text = get_visual_selection()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)

    if text == '' then
      return
    end

    local query = vim.fn.input {
      prompt = 'Grep: ',
      default = text:gsub('\n', ' '),
    }
    if query ~= '' then
      grep_picker(query)
    end
  end, { desc = 'Grep selection with prompt' })

  map('n', '<leader>ll', function()
    local query = vim.fn.input 'Grep: '
    if query ~= '' then
      grep_picker(query)
    end
  end, { desc = 'Grep prompt' })

  map('n', '<leader>l', function()
    vim.o.operatorfunc = 'v:lua.grep_operator'
    return 'g@'
  end, { desc = 'Grep operator', expr = true, noremap = true, silent = true })

  map('n', '<leader>lw', function()
    vim.o.operatorfunc = 'v:lua.grep_operator'
    return 'g@iw'
  end, { desc = 'Grep word under cursor', expr = true, noremap = true, silent = true })

  vim.api.nvim_create_user_command('Grep', function(cmd_opts)
    grep_picker(cmd_opts.args)
  end, { force = true, nargs = 1 })
end

return M
