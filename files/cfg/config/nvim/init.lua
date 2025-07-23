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
require("autocmds")
require("keymaps")

local function load_enabled_plugins()
  local plugins_file = vim.fn.stdpath("config") .. "/plugins"
  local plugins = {}

  local file = io.open(plugins_file, "r")
  if not file then
    return {}
  end

  for line in file:lines() do
    line = line:match("^%s*(.-)%s*$")
    if line ~= "" and not line:match("^#") then
      table.insert(plugins, require("plugins." .. line))
    end
  end

  file:close()
  return plugins
end

require("lazy").setup({
  spec = {
    load_enabled_plugins(),
  },
  change_detection = {
    enabled = false,
    notify = false,
  },
})

-- vim.api.nvim_create_autocmd("User", {
--   pattern = "VeryLazy",
--   callback = function()
--     if package.loaded["lualine"] and pcall(require, "focus") then
--       vim.cmd([[Zen]])
--     elseif pcall(require, "focus") then
--       vim.cmd([[Zen]])
--     end
--   end,
-- })

if pcall(require, "focus") then
  vim.cmd([[Zen]])
end

-- vim.api.nvim_set_hl(0, "FloatBorder", {
--   fg = "#999999",
--   bg = "NONE",
-- })

vim.filetype.add({
  extension = {
    ["env"] = "bash",
    ["templ"] = "templ",
    ["sls"] = "scheme",
  },
  filename = {
    [".env"] = "bash",
    ["plugins"] = "conf",
    ["plugins.example"] = "conf",
    ["uv.lock"] = "toml",
    [".env.template"] = "bash",
    [".env.example"] = "bash",
    ["poetry.lock"] = "toml",
    ["composer.lock"] = "json",
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
