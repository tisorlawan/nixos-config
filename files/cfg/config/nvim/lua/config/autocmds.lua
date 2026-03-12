local M = {}

local colorcolumn = require 'config.colorcolumn'
local whitespace = require 'config.whitespace'

local augroup = vim.api.nvim_create_augroup('UserConfig', { clear = true })

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

local sh_scratch_buf
local sh_scratch_win

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
  local current_win = vim.api.nvim_get_current_win()

  if not sh_scratch_buf or not vim.api.nvim_buf_is_valid(sh_scratch_buf) then
    vim.cmd(vim.api.nvim_win_get_width(0) > vim.api.nvim_win_get_height(0) * 1.5 and 'vnew' or 'new')
    sh_scratch_buf = vim.api.nvim_get_current_buf()
    sh_scratch_win = vim.api.nvim_get_current_win()
    vim.bo[sh_scratch_buf].buftype = 'nofile'
    vim.bo[sh_scratch_buf].bufhidden = 'wipe'
    vim.api.nvim_set_current_win(current_win)
  elseif not sh_scratch_win or not vim.api.nvim_win_is_valid(sh_scratch_win) then
    vim.cmd(vim.api.nvim_win_get_width(0) > vim.api.nvim_win_get_height(0) * 1.5 and 'vsplit' or 'split')
    vim.api.nvim_win_set_buf(0, sh_scratch_buf)
    sh_scratch_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(current_win)
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

function M.setup()
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

  vim.api.nvim_create_autocmd('BufWritePre', {
    group = augroup,
    callback = function(event)
      if vim.bo[event.buf].buftype ~= '' or not vim.bo[event.buf].modifiable then
        return
      end

      local filetype = vim.bo[event.buf].filetype
      if whitespace.enabled_by_ft[filetype] then
        whitespace.trim(event.buf)
      end
    end,
  })

  vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = vim.tbl_keys(colorcolumn.rules),
    callback = colorcolumn.apply,
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
      vim.opt_local.lispwords:append {
        'deftest',
        'defsuite',
        'define-test',
        'defspec',
        'describe',
        'it',
        'context',
        'before',
        'after',
        'around',
        'with-gensyms',
      }
      vim.keymap.set('n', '<leader>uu', '<cmd>ToggleParinfer<cr>', { buffer = true, desc = 'Toggle parinfer' })
      vim.bo.lisp = false
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
    pattern = 'qf',
    callback = function(event)
      vim.keymap.set('n', 'q', '<cmd>cclose<CR>', { buffer = event.buf, desc = 'Close quickfix' })
    end,
  })

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

      local quickfix = vim.fn.getqflist { title = 1 }
      local title = quickfix.title or ''
      if title:match '^Grep:' then
        return
      end

      vim.api.nvim_buf_set_name(vim.api.nvim_get_current_buf(), '[Quickfix]')
    end,
  })

  vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = 'sh',
    callback = function(event)
      vim.keymap.set('n', '<CR>', run_sh_scratch, { buffer = true, desc = 'Run shell script in scratch' })
      vim.api.nvim_create_autocmd('BufWritePost', {
        buffer = event.buf,
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

end

return M
