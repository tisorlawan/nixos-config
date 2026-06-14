local M = {}

local repl_keymaps_augroup = vim.api.nvim_create_augroup('UserLispReplKeymaps', { clear = true })

local function setup_repl_keymaps(buf)
  if vim.b[buf].slimv_repl_buffer ~= 1 then
    return
  end

  vim.keymap.set('i', '<C-h>', function()
    vim.cmd.stopinsert()
    vim.cmd.wincmd 'h'
  end, { buffer = buf, desc = 'Move to left window' })
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
  group = repl_keymaps_augroup,
  callback = function(event)
    setup_repl_keymaps(event.buf)
  end,
})

local function parinfer_plugin_dir()
  return vim.fs.joinpath(vim.fn.stdpath 'data', 'site', 'pack', 'core', 'opt', 'parinfer-rust')
end

local function parinfer_library_path()
  return vim.fs.joinpath(parinfer_plugin_dir(), 'target', 'release', 'libparinfer_rust.so')
end

local function ensure_parinfer_built()
  if vim.uv.fs_stat(parinfer_library_path()) then
    return true
  end

  if vim.fn.executable 'cargo' ~= 1 or not vim.uv.fs_stat(parinfer_plugin_dir()) then
    return false
  end

  local result = vim.system({ 'cargo', 'build', '--release' }, { cwd = parinfer_plugin_dir(), text = true, env = { CARGO_TARGET_DIR = 'target' } }):wait()
  if result.code ~= 0 then
    vim.notify(result.stderr ~= '' and result.stderr or 'Failed to build parinfer-rust', vim.log.levels.WARN)
    return false
  end

  return vim.uv.fs_stat(parinfer_library_path()) ~= nil
end

local function ensure_commands()
  if vim.fn.exists ':ToggleParinfer' ~= 0 then
    return
  end

  vim.api.nvim_create_user_command('ToggleParinfer', function()
    if vim.fn.exists ':ParinferOn' == 0 or vim.fn.exists ':ParinferOff' == 0 then
      vim.notify('Parinfer is not available in this buffer', vim.log.levels.WARN)
      return
    end

    local enabled = vim.g.parinfer_enabled ~= 0
    vim.cmd(enabled and 'ParinferOff' or 'ParinferOn')
    vim.notify(string.format('Parinfer %s', enabled and 'disabled' or 'enabled'), vim.log.levels.INFO)
  end, { desc = 'Toggle parinfer', force = true })
end

local function feed_normal_keys(keys)
  vim.cmd.stopinsert()

  vim.schedule(function()
    local termcodes = vim.api.nvim_replace_termcodes(keys .. 'a', true, false, true)
    vim.api.nvim_feedkeys(termcodes, 'm', false)
  end)
end

function M.setup_buffer(ft)
  if require('shared').get_used_filetypes().enabled.lisp ~= true then
    return
  end

  -- vim.opt_local.lispwords:remove { 'when' }

  vim.cmd.packadd 'slimv'
  vim.cmd('runtime ftplugin/' .. ft .. '/slimv-' .. ft .. '.vim')

  if ensure_parinfer_built() then
    vim.g.parinfer_dylib_path = parinfer_library_path()
    vim.cmd.packadd 'parinfer-rust'
  end

  ensure_commands()
  vim.keymap.set('n', '<leader>uu', '<cmd>ToggleParinfer<cr>', { buffer = true, desc = 'Toggle parinfer' })
  vim.keymap.set('i', '<C-x><C-e>', function()
    feed_normal_keys ',e'
  end, { buffer = true, desc = 'Eval current exp' })
  vim.keymap.set('i', '<C-x><C-b>', function()
    feed_normal_keys ',b'
  end, { buffer = true, desc = 'Eval buffer' })
  setup_repl_keymaps(0)
end

return M
