local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("options")
require("lazy").setup({
  spec = {
    {
      -- require("plugins.avante"),
      require("plugins.arrow"),
      -- require("plugins.asterisks"),
      require("plugins.autopairs"),
      -- require("plugins.bqf"),
      -- require("plugins.colorizer"),
      require("plugins.colorschema"),
      require("plugins.conform"),
      -- require("plugins.debugprint"),
      require("plugins.dirvish"),
      -- require("plugins.dressing"),
      -- require("plugins.flit"),
      require("plugins.focus"),
      require("plugins.fzf"),
      require("plugins.gitignore"),
      require("plugins.gitsigns"),
      require("plugins.leap"),
      require("plugins.lsp"),
      -- require("plugins.lualine"),
      require("plugins.mini"),
      -- require("plugins.multicursor"),
      require("plugins.neotree"),
      -- require("plugins.noice"),
      require("plugins.nvim-lint"),
      -- require("plugins.outline"),
      -- require("plugins.persistence"),
      -- require("plugins.richclip"),
      -- require("plugins.scrolleof"),
      require("plugins.smartsplit"),
      -- require("plugins.snacks"),
      -- require("plugins.suda"),
      -- require("plugins.todo-comments"),
      -- require("plugins.toggleterm"),
      -- require("plugins.treesitter"),
      require("plugins.trouble"),
      -- require("plugins.ufo"),
      -- require("plugins.undotree"),
      -- require("plugins.unified"),
      require("plugins.vim-cool"),
      -- require("plugins.whichkey"),
      -- require("plugins.yazi"),
    },
  },
  change_detection = {
    enabled = false,
    notify = false,
  },
})
require("keymaps")
require("autocmds")

vim.api.nvim_set_hl(0, "FloatBorder", {
  fg = "#a0a0a0",
  bg = "NONE",
})

vim.filetype.add({
  extension = {
    ["env"] = "bash",
    ["templ"] = "templ",
    ["sls"] = "scheme",
  },
  filename = {
    [".env"] = "bash",
    ["uv.lock"] = "toml",
    [".env.template"] = "bash",
    [".env.example"] = "bash",
    ["poetry.lock"] = "toml",
    ["composer.lock"] = "json",
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
