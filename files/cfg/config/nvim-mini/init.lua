require("options")
require("keymaps")
require("autocmds")

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
  vim.keymap.set("n", "-", function()
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

-- stylua: ignore
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
  --------------------------------------------------------------------
  add({
    source = "mrjones2014/smart-splits.nvim",
  })
  local s = require("smart-splits")
  s.setup({
    ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
    ignored_buftypes = { "nofile" },
  })

  vim.keymap.set({ "n" }, "<C-h>", function() require("smart-splits").move_cursor_left() end)
  vim.keymap.set({ "n" }, "<C-k>", function() require("smart-splits").move_cursor_up() end)
  vim.keymap.set({ "n" }, "<C-j>", function() require("smart-splits").move_cursor_down() end)
  vim.keymap.set({ "n" }, "<C-l>", function() require("smart-splits").move_cursor_right() end)
  --------------------------------------------------------------------
  add({
    source = "otavioschwanck/arrow.nvim",
  })
  require("arrow").setup({
    show_icons = true,
    leader_key = ";",
    buffer_leader_key = "m",
  })
  vim.keymap.set("n", "H", require("arrow.persist").previous)
  vim.keymap.set("n", "L", require("arrow.persist").next)
  vim.keymap.set("n", "<M-1>", function() require("arrow.persist").go_to(1) end)
  vim.keymap.set("n", "<M-2>", function() require("arrow.persist").go_to(2) end)
  vim.keymap.set("n", "<M-3>", function() require("arrow.persist").go_to(3) end)
  vim.keymap.set("n", "<leader>1", function() require("arrow.persist").go_to(1) end)
  vim.keymap.set("n", "<leader>2", function() require("arrow.persist").go_to(2) end)
  vim.keymap.set("n", "<leader>3", function() require("arrow.persist").go_to(3) end)
  vim.keymap.set("n", "<leader>4", function() require("arrow.persist").go_to(4) end)
  --------------------------------------------------------------------
  add({ source = "tisorlawan/vim-asterisk" })
  vim.cmd([[
      map *   <Plug>(asterisk-z*)
      map #   <Plug>(asterisk-z#)
      map g*  <Plug>(asterisk-gz*)
      map g#  <Plug>(asterisk-gz#)
      map z*  <Plug>(asterisk-*)
      map gz* <Plug>(asterisk-z*)
      map z#  <Plug>(asterisk-#)
      map gz# <Plug>(asterisk-z#)
      let g:asterisk#keeppos = 1
    ]])
end)
