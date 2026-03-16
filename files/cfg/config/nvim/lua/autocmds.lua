local augroup = vim.api.nvim_create_augroup('UserConfig', { clear = true })
local colorcolumn = require 'self.colorcolumn'

vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  callback = function()
    vim.highlight.on_yank { timeout = 150 }
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'qf', 'help', 'man', 'lspinfo', 'checkhealth', 'notify', 'spectre_panel' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
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
  pattern = vim.tbl_keys(colorcolumn.rules),
  callback = colorcolumn.apply,
})

local cache_cols = vim.o.columns
local win_widths = {}

local function save_widths()
  cache_cols = vim.o.columns
  win_widths = {}
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_config(w).relative == '' then
      win_widths[w] = vim.api.nvim_win_get_width(w)
    end
  end
end

save_widths()

vim.api.nvim_create_autocmd({ 'WinNew', 'WinClosed', 'BufWinEnter' }, {
  group = augroup,
  callback = vim.schedule_wrap(save_widths),
})

vim.api.nvim_create_autocmd('VimResized', {
  group = augroup,
  callback = function()
    local nc = vim.o.columns
    if cache_cols > 0 then
      local scale = nc / cache_cols
      for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local ww = win_widths[w]
        if ww and vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_config(w).relative == '' then
          vim.api.nvim_win_set_width(w, math.max(1, math.floor(ww * scale)))
        end
      end
    end
    save_widths()
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup,
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(event.buf) then
      vim.api.nvim_win_set_cursor(0, { mark[1], mark[2] })
    end
  end,
})
