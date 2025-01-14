require("options")
require("keymaps")

local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"

if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/echasnovski/mini.nvim",
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd("packadd mini.nvim | helptags ALL")
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require("mini.deps").setup({ path = { package = path_package } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function()
  vim.o.termguicolors = true
end)

now(function()
  require("mini.icons").setup()
  require("mini.statusline").setup()
  require("mini.starter").setup()
  require("mini.completion").setup()
  require("mini.pairs").setup()
end)

now(function()
  require("mini.files").setup()
  vim.keymap.set("n", "<leader>e", function()
    require("mini.files").open(vim.api.nvim_buf_get_name(0))
  end)
  vim.keymap.set("n", "<leader>E", function()
    require("mini.files").open()
  end)
end)

-- stylua: ignore
later(function()
  require("mini.pick").setup()
  vim.keymap.set("n", "<c-p>", function() require("mini.pick").builtin.files({}) end)
  vim.keymap.set("n", "<c-n>", function() require("mini.pick").builtin.buffers({}) end)
  vim.keymap.set("n", "<leader>sg", function() require("mini.pick").builtin.grep_live({}) end)
end)

later(function()
  -------------------------------------------------------------------
  add({
    source = "nvim-treesitter/nvim-treesitter",
    checkout = "master",
    monitor = "main",
    hooks = {
      post_checkout = function()
        vim.cmd("TSUpdate")
      end,
    },
  })
  -------------------------------------------------------------------
  add({ source = "rebelot/kanagawa.nvim" })
  vim.cmd("colorscheme kanagawa-dragon")
  -------------------------------------------------------------------
  add({
    source = "ggandor/leap.nvim",
    depends = { "tpope/vim-repeat" },
  })
  require("leap").setup({
    safe_labels = "tyuofghjklvbn",
    labels = "sfnjklhowembuyvrgtqpcxz/SFNJKLHOWEIMBUYVRGTAQPCXZ",
  })
  vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward-to)", { desc = "leap forward to" })
  vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward-to)", { desc = "leap backward to" })
  vim.keymap.set({ "x", "o" }, "x", "<Plug>(leap-forward-till)", { desc = "leap forward till" })
  vim.keymap.set({ "x", "o" }, "X", "<Plug>(leap-backward-till)", { desc = "leap backward till" })
  vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)", { desc = "leap from window" })
end)
