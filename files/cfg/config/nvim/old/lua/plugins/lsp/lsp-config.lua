local cfg = require("plugins.lsp.config")

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

local installed_servers = {}

for _, server in pairs(servers) do
  if not utils.contains(servers_install_skip, server) then
    table.insert(installed_servers, server)
  end
end

local function setup_diagnostic()
  vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "diagnostic line" })
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "prev diagnostic" })
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "next diagnostic" })

  local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = false,
    update_in_insert = false,
    severity_sort = true,
  })
end

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    { "williamboman/mason.nvim", config = true },
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    {
      "j-hui/fidget.nvim",
      opts = {
        notification = {
          window = {
            winblend = 0,
          },
        },
      },
      ft = { "rust", "python", "lua", "go" },
    },
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
      callback = function(event)
        setup_diagnostic()
        cfg.on_attach(event)
      end,
    })

    require("mason").setup()

    require("mason-tool-installer").setup({
      ensure_installed = vim.list_extend(cfg.mason_linter_install, cfg.mason_formatter_install),
    })

    -- LSP servers and clients are able to communicate to each other what features they support.
    --  By default, Neovim doesn't support everything that is in the LSP specification.
    --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
    --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    -- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

    require("mason-lspconfig").setup({
      ensure_installed = installed_servers,
    })

    local lspconfig = require("lspconfig")
    local handlers = vim.lsp.handlers
    local border = {
      { "🭽", "FloatBorder" },
      { "▔", "FloatBorder" },
      { "🭾", "FloatBorder" },
      { "▕", "FloatBorder" },
      { "🭿", "FloatBorder" },
      { "▁", "FloatBorder" },
      { "🭼", "FloatBorder" },
      { "▏", "FloatBorder" },
    }
    handlers["textDocument/hover"] = vim.lsp.with(handlers.hover, { border = border })
    handlers["textDocument/signatureHelp"] = vim.lsp.with(handlers.signature_help, { border = border })

    for _, sn in pairs(servers) do
      if not utils.contains(servers_config_skip, sn) then
        local c = cfg.config[sn]
        local merged_cfg = vim.tbl_deep_extend("force", { capabilities = capabilities, handlers = handlers }, c or {})

        merged_cfg.capabilities = require("blink.cmp").get_lsp_capabilities(merged_cfg.capabilities)

        lspconfig[sn].setup(merged_cfg)
      end
    end
  end,
}
