local cfg = require("lsp_config")

local utils = require("utils")

-- some lsp is setup by separate plugins
local servers_config_skip = { "tsserver", "rust_analyzer" }
-- local servers_config_skip = {}

local servers_install_skip = { "clangd", "rust_analyzer" }

if utils.is_nixos() then
  table.insert(servers_install_skip, "ruff")
  table.insert(servers_install_skip, "lua_ls")
  table.insert(servers_install_skip, "marksman")
  table.insert(servers_install_skip, "gopls")
  table.insert(servers_install_skip, "nil_ls")
  table.insert(servers_install_skip, "prettierd")
  table.insert(servers_install_skip, "pyright")
  table.insert(servers_install_skip, "zls")
  table.insert(servers_install_skip, "hls")
end

local servers = cfg.mason_lspserver

local config = {}
for _, sn in pairs(servers) do
  if not utils.contains(servers_config_skip, sn) then
    local c = cfg.config[sn]
    if c then
      config[sn] = c
    else
      config[sn] = {}
    end

    if utils.contains(servers_install_skip, sn) then
      config[sn].mason = false
    end
  end
end

local plugins = {
  {
    "neovim/nvim-lspconfig",
    dependencies = {},
    opts = function(_, opts)
      opts.servers = config
      opts.inlay_hints = {
        enabled = false,
      }

      local keys = require("lazyvim.plugins.lsp.keymaps").get()

      keys[#keys + 1] = { "gr", vim.lsp.buf.references, desc = "Go to references" }
      keys[#keys + 1] = { "gd", vim.lsp.buf.definition, desc = "Go to definition" }
      keys[#keys + 1] = { "gD", vim.lsp.buf.declaration, desc = "Go to definition" }
      keys[#keys + 1] = { "gm", ":vsplit | lua vim.lsp.buf.definition()<cr>", desc = "Goto Definition Vsplit" }
      keys[#keys + 1] = { "gy", vim.lsp.buf.type_definition, desc = "Goto Type Definition" }
      keys[#keys + 1] = { "gi", vim.lsp.buf.implementation, desc = "Goto Implementation" }
      keys[#keys + 1] = { "<leader>k", vim.lsp.buf.signature_help, desc = "Signature Help" }
    end,
  },
}

local ft_plugins = {
  go = require("langs.go"),
  python = require("langs.python"),
  markdown = require("langs.markdown").plugins,
  typescript = require("langs.typescript"),
  norg = require("langs.neorg"),
  rust = require("langs.rust"),
  elixir = require("langs.elixir"),
}

local used_ft = require("lsp_config").used_ft
for ft, plugin in pairs(ft_plugins) do
  if require("utils").contains(used_ft, ft) then
    table.insert(plugins, plugin)
  end
end

return plugins
