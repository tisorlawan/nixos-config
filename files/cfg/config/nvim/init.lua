require("options")
require("mappings")
require("autocmds")
require("filetypes")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

local plugins = {
  require("plugins.dirvish"),
  require("plugins.comment"),
  require("plugins.fzf"),
  require("plugins.git"),
  require("plugins.treesitter"),
  require("plugins.neotree"),
  require("plugins.nvim-autopairs"),
  require("plugins.lualine"),
  require("plugins.todo-comments"),
  require("plugins.leap"),
  require("plugins.flit"),
  require("plugins.vim-grepper"),
  require("plugins.mini"),
  require("plugins.scroll-eof"),
  require("plugins.numb"),
  require("plugins.gitignore"),
  require("plugins.suda"),
  require("plugins.undotree"),
  require("plugins.multicursors"),
  require("plugins.executor"),
  require("plugins.harpoon"),
  require("plugins.lastplace"),
  require("plugins.which-key"),
  require("plugins.smart-splits"),
  require("plugins.ufo"),
  require("plugins.colorscheme"),
  require("plugins.yazi"),
  require("plugins.dressing"),

  require("plugins.lsp"),
}
local ft_plugins = {
  rust = require("plugins.langs.rust"),
  go = require("plugins.langs.go"),
  python = require("plugins.langs.python"),
  markdown = require("plugins.langs.markdown").plugins,
  typescript = require("plugins.langs.typescript"),
  norg = require("plugins.langs.neorg"),
}

local used_ft = require("plugins.lsp.config").used_ft
for ft, plugin in pairs(ft_plugins) do
  if require("utils").contains(used_ft, ft) then
    table.insert(plugins, plugin)
  end
end

local ui = {
  icons = vim.g.have_nerd_font and {} or {
    cmd = "⌘",
    config = "🛠",
    event = "📅",
    ft = "📂",
    init = "⚙",
    keys = "🗝",
    plugin = "🔌",
    runtime = "💻",
    require = "🌙",
    source = "📄",
    start = "🚀",
    task = "📌",
    lazy = "💤 ",
  },
}

require("lazy").setup(plugins, {
  ui = ui,
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
