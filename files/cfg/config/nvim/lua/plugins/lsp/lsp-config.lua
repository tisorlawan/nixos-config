local cfg = require("plugins.lsp.config")

local utils = require("utils")

-- some lsp is setup by separate plugins
local servers_config_skip = { "tsserver", "rust_analyzer" }
-- local servers_config_skip = {}

local servers_install_skip = { "clangd", "rust_analyzer" }

if utils.is_nixos() then
  table.insert(servers_install_skip, "ruff_lsp")
  table.insert(servers_install_skip, "lua_ls")
  table.insert(servers_install_skip, "marksman")
  table.insert(servers_install_skip, "gopls")
  table.insert(servers_install_skip, "nil_ls")
  table.insert(servers_install_skip, "prettierd")
  table.insert(servers_install_skip, "pyright")
  table.insert(servers_install_skip, "zls")
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
        -- local map = function(keys, func, desc)
        --   vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        -- end

        -- -- Jump to the definition of the word under your cursor.
        -- --  This is where a variable was first declared, or where a function is defined, etc.
        -- --  To jump back, press <C-t>.
        -- -- map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

        -- -- Find references for the word under your cursor.
        -- -- map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

        -- -- Jump to the implementation of the word under your cursor.
        -- --  Useful when your language has ways of declaring types without an actual implementation.
        -- -- map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

        -- -- Jump to the type of the word under your cursor.
        -- --  Useful when you're not sure what type a variable is and you want to see
        -- --  the definition of its *type*, not where it was *defined*.
        -- -- map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

        -- -- Fuzzy find all the symbols in your current document.
        -- --  Symbols are things like variables, functions, types, etc.
        -- -- map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

        -- -- Fuzzy find all the symbols in your current workspace.
        -- --  Similar to document symbols, except searches over your entire project.
        -- -- map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- -- Rename the variable under your cursor.
        -- --  Most Language Servers support renaming across files, etc.
        -- map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- -- Execute a code action, usually your cursor needs to be on top of an error
        -- -- or a suggestion from your LSP for this to activate.
        -- map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        -- -- Opens a popup that displays documentation about the word under your cursor
        -- --  See `:help K` for why this keymap.
        -- map('K', vim.lsp.buf.hover, 'Hover Documentation')

        -- -- WARN: This is not Goto Definition, this is Goto Declaration.
        -- --  For example, in C this would take you to the header.
        -- map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- -- The following two autocommands are used to highlight references of the
        -- -- word under your cursor when your cursor rests there for a little while.
        -- --    See `:help CursorHold` for information about when this is executed
        -- --
        -- -- When you move your cursor, the highlights will be cleared (the second autocommand).
        -- local client = vim.lsp.get_client_by_id(event.data.client_id)
        -- if client and client.server_capabilities.documentHighlightProvider then
        --   local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        --   vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        --     buffer = event.buf,
        --     group = highlight_augroup,
        --     callback = vim.lsp.buf.document_highlight,
        --   })

        --   vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        --     buffer = event.buf,
        --     group = highlight_augroup,
        --     callback = vim.lsp.buf.clear_references,
        --   })

        --   vim.api.nvim_create_autocmd('LspDetach', {
        --     group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        --     callback = function(event2)
        --       vim.lsp.buf.clear_references()
        --       vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        --     end,
        --   })
        -- end

        -- -- The following autocommand is used to enable inlay hints in your
        -- -- code, if the language server you are using supports them
        -- --
        -- -- This may be unwanted, since they displace some of your code
        -- if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
        --   map('<leader>th', function()
        --     vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        --   end, '[T]oggle Inlay [H]ints')
        -- end
      end,
    })

    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --
    --  Add any additional override configuration in the following tables. Available keys are:
    --  - cmd (table): Override the default command used to start the server
    --  - filetypes (table): Override the default list of associated filetypes for the server
    --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
    --  - settings (table): Override the default settings passed when initializing the server.
    --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
    -- local servers = {
    --   -- clangd = {},
    --   -- gopls = {},
    --   -- pyright = {},
    --   -- rust_analyzer = {},
    --   -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
    --   --
    --   -- Some languages (like typescript) have entire language plugins that can be useful:
    --   --    https://github.com/pmizio/typescript-tools.nvim
    --   --
    --   -- But for many setups, the LSP (`tsserver`) will work just fine
    --   -- tsserver = {},
    --   --

    --   lua_ls = {
    --     -- cmd = {...},
    --     -- filetypes = { ...},
    --     -- capabilities = {},
    --     settings = {
    --       Lua = {
    --         completion = {
    --           callSnippet = 'Replace',
    --         },
    --         -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
    --         -- diagnostics = { disable = { 'missing-fields' } },
    --       },
    --     },
    --   },
    -- }

    -- Ensure the servers and tools above are installed
    --  To check the current status of installed tools and/or manually install
    --  other tools, you can run
    --    :Mason
    --
    --  You can press `g?` for help in this menu.
    require("mason").setup()

    require("mason-tool-installer").setup({
      ensure_installed = vim.list_extend(cfg.mason_linter_install, cfg.mason_formatter_install),
    })

    -- LSP servers and clients are able to communicate to each other what features they support.
    --  By default, Neovim doesn't support everything that is in the LSP specification.
    --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
    --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

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

        lspconfig[sn].setup(merged_cfg)
      end
    end
  end,
}
