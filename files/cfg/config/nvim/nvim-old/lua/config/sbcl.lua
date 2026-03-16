local M = {}

local sbcl_output_buf
local sbcl_output_win
local last_expr_ns = vim.api.nvim_create_namespace 'sbcl_last_expr'
local flash_ns = vim.api.nvim_create_namespace 'sbcl_flash'
local last_expr_buf
local last_expr_start_mark
local last_expr_end_mark

local function flash_range(buf, start_row, start_col, end_row, end_col)
  vim.highlight.range(buf, flash_ns, 'IncSearch', { start_row, start_col }, { end_row, end_col })
  vim.defer_fn(function()
    pcall(vim.api.nvim_buf_clear_namespace, buf, flash_ns, 0, -1)
  end, 150)
end

local function decode_protocol_value(value)
  if value == nil then
    return value
  end

  local quoted = value:match '^"(.*)"$'
  if not quoted then
    return value
  end

  local map = {
    n = '\n',
    r = '\r',
    t = '\t',
    a = '\a',
    b = '\b',
    f = '\f',
    v = '\v',
    ['"'] = '"',
    ['\\'] = '\\',
  }

  return quoted:gsub('\\(.)', function(ch)
    return map[ch] or ch
  end)
end

local function strip_outer_quotes(text)
  if text == nil then
    return text
  end
  if text:sub(1, 1) == '"' and text:sub(-1) == '"' then
    return text:sub(2, -2)
  end
  return text
end

local function set_lines_in_scratch(buf, lines)
  vim.bo[buf].readonly = false
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
end

local function close_output_window()
  local win = vim.fn.bufwinid(sbcl_output_buf or -1)
  if win ~= -1 then
    vim.api.nvim_win_close(win, true)
  end
end

local function configure_output_window(win)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'
  vim.wo[win].foldcolumn = '0'
end

local function ensure_output_window()
  local win

  if sbcl_output_win and vim.api.nvim_win_is_valid(sbcl_output_win) then
    win = sbcl_output_win
  else
    local existing_win = vim.fn.bufwinid(sbcl_output_buf or -1)
    if existing_win ~= -1 then
      win = existing_win
    end
  end

  if not sbcl_output_buf or not vim.api.nvim_buf_is_valid(sbcl_output_buf) then
    sbcl_output_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[sbcl_output_buf].buftype = 'nofile'
    vim.bo[sbcl_output_buf].bufhidden = 'hide'
    vim.bo[sbcl_output_buf].swapfile = false
    vim.bo[sbcl_output_buf].buflisted = false
    vim.api.nvim_buf_set_name(sbcl_output_buf, '[SBCL Output]')
    vim.keymap.set('n', 'q', close_output_window, { buffer = sbcl_output_buf, silent = true })
  end

  if not win then
    vim.cmd.vsplit()
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, sbcl_output_buf)
  end

  vim.api.nvim_win_set_buf(win, sbcl_output_buf)
  configure_output_window(win)
  sbcl_output_win = win
  return win
end

local function show_output(message, level)
  local current_win = vim.api.nvim_get_current_win()
  local cleaned = type(message) == 'string' and strip_outer_quotes(vim.trim(message)) or ''
  local lines = type(cleaned) == 'string' and vim.split(cleaned, '\n', { plain = true, trimempty = false }) or {}
  if #lines == 0 then
    lines = { '(no output)' }
  end

  if level == vim.log.levels.ERROR then
    table.insert(lines, 1, '[error]')
  end

  local win = ensure_output_window()
  set_lines_in_scratch(sbcl_output_buf, lines)
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_cursor(win, { 1, 0 })
  end
  if current_win and vim.api.nvim_win_is_valid(current_win) then
    vim.api.nvim_set_current_win(current_win)
  end
end

local function wrap_expr_with_stdout_capture(expr)
  local template = [[(let* ((sbcl__stream (make-string-output-stream))
           (sbcl__values (multiple-value-list
                          (let ((*standard-output* sbcl__stream)
                                (*error-output* sbcl__stream)
                                (*trace-output* sbcl__stream))
                            %s))))
       (let ((result (if (= (length sbcl__values) 1) (car sbcl__values) sbcl__values))
             (output (get-output-stream-string sbcl__stream)))
         (if (string= output "")
             (format nil "~S" result)
             (format nil "~A~%%=> ~S" output result))))]]

  return string.format(template:gsub('\n', ' '), expr)
end

local function send(expr, label, on_result)
  local uv = vim.uv or vim.loop
  local client = uv.new_tcp()
  local response_chunks = {}

  local function notify_result(message, level)
    vim.schedule(function()
      local ok, err = pcall(function()
        if on_result then
          on_result(message, level)
        else
          vim.notify(message, level)
        end
      end)
      if not ok then
        vim.notify('Sbcl callback error: ' .. tostring(err), vim.log.levels.ERROR)
      end
    end)
  end

  local function parse_response(output)
    local parsed = {}
    local lines = vim.split(output, '\n', { plain = true, trimempty = false })
    local total_lines = #lines

    for index, raw in ipairs(lines) do
      local line = vim.trim(raw)
      local is_last_line = index == total_lines

      if line == 'OK READY' then
      elseif line == '' and is_last_line then
      else
        local text
        local level = vim.log.levels.INFO

        if line == 'OK' then
          text = '(no output)'
        elseif line:match '^OK%s' then
          text = decode_protocol_value(line:match '^OK%s*(.*)$' or '')
        elseif line:match '^ERR%s' then
          text = line:match '^ERR%s*(.*)$' or '(error)'
          if text == '' then
            text = '(error)'
          end
          level = vim.log.levels.ERROR
        elseif line == 'ERR' then
          text = '(error)'
          level = vim.log.levels.ERROR
        else
          text = line
        end

        table.insert(parsed, { text = text, level = level })
      end
    end

    if #parsed == 0 then
      table.insert(parsed, { text = '(no output)', level = vim.log.levels.INFO })
    end

    return parsed
  end

  local function flush_response(is_final)
    if #response_chunks == 0 then
      if is_final then
        notify_result(label .. ': (no output)', vim.log.levels.INFO)
        pcall(client.shutdown, client)
        pcall(client.close, client)
      end
      return
    end

    local parsed = parse_response(table.concat(response_chunks))
    local payload = {}
    local level = vim.log.levels.INFO

    for _, item in ipairs(parsed) do
      table.insert(payload, item.text)
      if item.level == vim.log.levels.ERROR then
        level = vim.log.levels.ERROR
      end
    end

    local final_payload = table.concat(payload, '\n')
    if final_payload == '' then
      final_payload = '(no output)'
    end

    notify_result(final_payload, level)

    if is_final then
      pcall(client.shutdown, client)
      pcall(client.close, client)
    end
  end

  if on_result then
    notify_result(label .. ': waiting for SBCL response...', vim.log.levels.INFO)
  end

  client:connect('127.0.0.1', 5677, function(err)
    if err then
      notify_result(label .. ': connection failed', vim.log.levels.ERROR)
      pcall(client.close, client)
      return
    end

    client:write(expr .. '\n', function(write_err)
      if write_err then
        notify_result(label .. ': send failed', vim.log.levels.ERROR)
        pcall(client.close, client)
        return
      end

      client:read_start(function(_, response)
        if not response then
          flush_response(true)
          return
        end

        table.insert(response_chunks, response)
        flush_response(false)
      end)
    end)
  end)
end

local function eval_expr(on_result)
  local filetype = vim.bo.filetype
  if filetype ~= 'lisp' and filetype ~= 'commonlisp' then
    vim.notify('SbclEvalExpr: not a lisp file (ft=' .. filetype .. ')', vim.log.levels.ERROR)
    return
  end

  local save = vim.fn.winsaveview()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local char = line:sub(col + 1, col + 1)
  local prev_char = col > 0 and line:sub(col, col) or ''
  local start
  local finish

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

  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, last_expr_ns, 0, -1)
  last_expr_buf = bufnr
  last_expr_start_mark = vim.api.nvim_buf_set_extmark(bufnr, last_expr_ns, start[1] - 1, start[2] - 1, {})
  last_expr_end_mark = vim.api.nvim_buf_set_extmark(bufnr, last_expr_ns, finish[1] - 1, finish[2] - 1, {})

  flash_range(bufnr, start[1] - 1, start[2] - 1, finish[1] - 1, finish[2] - 1)

  local lines = vim.api.nvim_buf_get_text(0, start[1] - 1, start[2] - 1, finish[1] - 1, finish[2], {})
  local expr = table.concat(lines, ' ')
  send(wrap_expr_with_stdout_capture(expr), 'SbclEvalExpr', on_result)
end

local function replay_last_expr(on_result)
  if not last_expr_buf or not vim.api.nvim_buf_is_valid(last_expr_buf) then
    vim.notify('SbclReplayExpr: no previous expression', vim.log.levels.ERROR)
    return
  end

  local ok_s, s = pcall(vim.api.nvim_buf_get_extmark_by_id, last_expr_buf, last_expr_ns, last_expr_start_mark, {})
  local ok_e, e = pcall(vim.api.nvim_buf_get_extmark_by_id, last_expr_buf, last_expr_ns, last_expr_end_mark, {})

  if not ok_s or not ok_e or #s == 0 or #e == 0 then
    vim.notify('SbclReplayExpr: lost track of expression', vim.log.levels.ERROR)
    return
  end

  flash_range(last_expr_buf, s[1], s[2], e[1], e[2])

  local lines = vim.api.nvim_buf_get_text(last_expr_buf, s[1], s[2], e[1], e[2] + 1, {})
  local expr = table.concat(lines, ' ')
  send(wrap_expr_with_stdout_capture(expr), 'SbclReplayExpr', on_result)
end

function M.setup()
  vim.api.nvim_create_user_command('SbclLoadFile', function()
    local filetype = vim.bo.filetype
    if filetype ~= 'lisp' and filetype ~= 'commonlisp' then
      vim.notify('SbclLoadFile: not a lisp file (ft=' .. filetype .. ')', vim.log.levels.ERROR)
      return
    end

    local filepath = vim.fn.expand '%:p'
    if filepath == '' then
      vim.notify('SbclLoadFile: no file in current buffer', vim.log.levels.ERROR)
      return
    end

    send(string.format('(load "%s")', filepath), 'SbclLoadFile', show_output)
  end, { force = true })

  vim.api.nvim_create_user_command('SbclEvalExpr', function()
    eval_expr(show_output)
  end, { force = true })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'lisp', 'commonlisp' },
    callback = function(event)
      vim.keymap.set('n', '<C-x><C-x>', '<cmd>write | SbclLoadFile<cr>', { buffer = event.buf, silent = true })
      vim.keymap.set('i', '<C-x><C-x>', function()
        vim.cmd.write()
        vim.cmd.SbclLoadFile()
        vim.cmd.startinsert()
      end, { buffer = event.buf, silent = true })
      vim.keymap.set('n', '<C-x><C-e>', '<cmd>SbclEvalExpr<cr>', { buffer = event.buf, silent = true })
      vim.keymap.set('n', '<cr>', '<cmd>SbclEvalExpr<cr>', { buffer = event.buf, silent = true })

      vim.keymap.set('i', '<C-x><C-e>', function()
        eval_expr(show_output)
        vim.cmd.startinsert()
      end, { buffer = event.buf, silent = true })

      vim.keymap.set('n', '<C-x><C-l>', function()
        replay_last_expr(show_output)
      end, { buffer = event.buf, silent = true })
      vim.keymap.set('n', '<C-CR>', function()
        replay_last_expr(show_output)
      end, { buffer = event.buf, silent = true })

      vim.keymap.set('i', '<C-x><C-l>', function()
        replay_last_expr(show_output)
        vim.cmd.startinsert()
      end, { buffer = event.buf, silent = true })
      vim.keymap.set('i', '<C-CR>', function()
        replay_last_expr(show_output)
        vim.cmd.startinsert()
      end, { buffer = event.buf, silent = true })
    end,
  })
end

function M.close_output()
  close_output_window()
end

return M
