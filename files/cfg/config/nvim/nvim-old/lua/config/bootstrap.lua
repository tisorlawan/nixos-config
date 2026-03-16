vim.g.python3_host_prog = vim.env.NVIM_PYTHON3_HOST_PROG or vim.fn.expand '~/.nix-profile/bin/python3'

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
  require('lazy').setup {
    spec = {
      { import = 'plugins' },
    },
    change_detection = { notify = false },
    ui = { border = 'single' },
    git = {
      log = { '-8' },
      timeout = 1200,
    },
  }

  vim.g.__user_lazy_setup_done = true
end
