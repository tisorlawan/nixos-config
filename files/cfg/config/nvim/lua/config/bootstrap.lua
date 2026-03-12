local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

---@diagnostic disable-next-line: undefined-field
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

if not vim.g.__user_lazy_setup_done then
  require('lazy').setup({
    spec = {
      { import = 'plugins' },
    },
    change_detection = { notify = false },
    ui = { border = 'rounded' },
  })

  vim.g.__user_lazy_setup_done = true
end
