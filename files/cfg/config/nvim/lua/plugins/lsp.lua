local utils = require("utils")
local fpath = vim.fn.stdpath("config") .. "/ft"
local used_ft = require("config.used_ft")

if utils.file_exists(fpath) then
  for line in io.lines(fpath) do
    local trimmed_line = utils.trim(line)
    if trimmed_line:len() > 0 and trimmed_line:sub(1, 1) ~= "#" and trimmed_line:sub(1, 4) ~= "vim:" then
      table.insert(used_ft, trimmed_line)
    end
  end
end

local formatters_to_mason = {
  clang_format = "clang-format",
  ruff_fix = "ruff",
  ruff_format = "ruff",
  ruff_organize_imports = "ruff",
  nixpkgs_fmt = "nixpkgs-fmt",
  php_cs_fixer = "php-cs-fixer",
}

local mason_lspserver = {}
for _, ft in pairs(used_ft) do
  for _, name in pairs((used_ft.config[ft] or {}).servers or {}) do
    table.insert(mason_lspserver, name)
  end
end

local mason_formatter_install = {}

for _, names in pairs(used_ft.formatters_by_ft) do
  for _, name in pairs(names) do
    local mason_name = formatters_to_mason[name]
    if mason_name == nil then
      mason_name = name
    end
    table.insert(mason_formatter_install, mason_name)
  end
end

if utils.is_nixos() then
  utils.remove_item_from_array(mason_formatter_install, "ruff")
  utils.remove_item_from_array(mason_formatter_install, "stylua")
  utils.remove_item_from_array(mason_formatter_install, "gofumpt")
  utils.remove_item_from_array(mason_formatter_install, "goimports")
  utils.remove_item_from_array(mason_formatter_install, "golines")
  utils.remove_item_from_array(mason_formatter_install, "prettierd")
  utils.remove_item_from_array(mason_formatter_install, "clang-format")
  utils.remove_item_from_array(mason_formatter_install, "nixpkgs-fmt")
  utils.remove_item_from_array(mason_formatter_install, "biome")
  utils.remove_item_from_array(mason_formatter_install, "rustfmt")
end
utils.remove_item_from_array(mason_formatter_install, "leptosfmt")
utils.remove_item_from_array(mason_formatter_install, "zigfmt")
utils.remove_item_from_array(mason_formatter_install, "mix")
utils.remove_item_from_array(mason_formatter_install, "cabal_fmt")
utils.remove_item_from_array(mason_formatter_install, "just")

local mason_linter_install = {}

local linters_to_mason = {}
for _, names in pairs(used_ft.linters_by_ft) do
  for _, name in pairs(names) do
    local mason_name = linters_to_mason[name]
    if mason_name == nil then
      mason_name = name
    end
    table.insert(mason_linter_install, mason_name)
  end
end

local function setup_lsp_keymaps(buf)
  local function map(key, fn, desc)
    vim.keymap.set("n", key, fn, { desc = desc, buffer = buf, silent = true })
  end

  local function vnmap(key, fn, desc)
    vim.keymap.set({ "n", "v" }, key, fn, { desc = desc, buffer = buf })
  end

  map("gD", vim.lsp.buf.declaration, "Goto Declaration")
  map("gd", vim.lsp.buf.definition, "Goto Definition")
  map("gm", ":vsplit | lua vim.lsp.buf.definition()<cr>", "Goto Definition Vsplit")
  map("K", vim.lsp.buf.hover, "Hover")
  map("gi", vim.lsp.buf.implementation, "Goto Implementation")
  map("<leader>k", vim.lsp.buf.signature_help, "Signature Help")
  map("gy", vim.lsp.buf.type_definition, "Goto Type Definition")
  -- map("<leader>rn", vim.lsp.buf.rename, "Rename")
  map("gr", vim.lsp.buf.references, "Goto References")

  -- map('<leader>lw', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')
  -- map('<leader>ld', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')

  local ok_fzf, _ = pcall(require, "fzf-lua")
  if ok_fzf then
    vnmap("<leader>ca", "<cmd>lua require('fzf-lua').lsp_code_actions()<cr>", "Code action (FZF Lua)")
    vnmap("<leader>cA", vim.lsp.buf.code_action, "Code action")
  else
    vnmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
  end
end

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

local installed_servers = {}

for _, server in pairs(mason_lspserver) do
  if not utils.contains(servers_install_skip, server) then
    table.insert(installed_servers, server)
  end
end

local function setup_diagnostic()
  vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "diagnostic line" })
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "prev diagnostic" })
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "next diagnostic" })
  vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

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

local function on_attach(ev)
  vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc" -- Enable completion triggered by <c-x><c-o>
  setup_lsp_keymaps(ev.buf)

  -- disable semantic tokens
  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  if client ~= nil then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

local config = {
  pyright = {
    settings = {
      python = {
        analysis = {
          autoImportCompletions = false,
          autoSearchPaths = false,
          useLibraryCodeForTypes = false,
          diagnosticMode = "openFilesOnly", -- "off"
          -- typeCheckingMode = "off",
          stubPath = "~/.typings",
        },
      },
    },
  },

  html = {
    filetypes = { "html", "php" },
  },

  tailwindcss = {
    userLanguages = {
      elixir = "html-eex",
      eelixir = "html-eex",
      heex = "html-eex",
    },
    settings = {
      includeLanguages = {
        typescript = "javascript",
        typescriptreact = "javascript",
        ["html-eex"] = "html",
        ["phoenix-heex"] = "html",
        heex = "html",
        eelixir = "html",
        elixir = "html",
        elm = "html",
        erb = "html",
        svelte = "html",
        rust = "html",
      },
      tailwindCSS = {
        lint = {
          cssConflict = "warning",
          invalidApply = "error",
          invalidConfigPath = "error",
          invalidScreen = "error",
          invalidTailwindDirective = "error",
          invalidVariant = "error",
          recommendedVariantOrder = "warning",
        },
        experimental = {
          classRegex = {
            'class="([^"]*)',
            'class: "([^"]*)',
            'with_cn\\("([^"]*)',
            'c\\("([^"]*)',
            'class\\("([^"]*)',
            'class[:]\\s*"([^"]*)"',
          },
        },
        validate = true,
      },
    },
    filetypes = {
      "css",
      "elixir",
      "eruby",
      "heex",
      "html",
      "blade",
      "php",
      "javascript",
      "javascriptreact",
      "rust",
      "sass",
      "scss",
      "svelte",
      "typescript",
      "typescriptreact",
    },
  },
}

local plugins = {
  {
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
        enabled = false,
        ft = { "rust", "python", "lua", "go" },
      },
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          setup_diagnostic()
          on_attach(event)
        end,
      })

      require("mason").setup()

      require("mason-tool-installer").setup({
        ensure_installed = vim.list_extend(mason_linter_install, mason_formatter_install),
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
      -- local border = {
      --   { "🭽", "FloatBorder" },
      --   { "▔", "FloatBorder" },
      --   { "🭾", "FloatBorder" },
      --   { "▕", "FloatBorder" },
      --   { "🭿", "FloatBorder" },
      --   { "▁", "FloatBorder" },
      --   { "🭼", "FloatBorder" },
      --   { "▏", "FloatBorder" },
      -- }
      -- handlers["textDocument/hover"] = vim.lsp.with(handlers.hover, { border = border })
      -- handlers["textDocument/signatureHelp"] = vim.lsp.with(handlers.signature_help, { border = border })

      for _, sn in pairs(mason_lspserver) do
        if not utils.contains(servers_config_skip, sn) then
          local c = config[sn]
          local merged_cfg = vim.tbl_deep_extend("force", { capabilities = capabilities, handlers = handlers }, c or {})

          merged_cfg.capabilities = require("blink.cmp").get_lsp_capabilities(merged_cfg.capabilities)

          lspconfig[sn].setup(merged_cfg)
        end
      end
    end,
  },
  {
    "saghen/blink.cmp",
    lazy = false,
    version = "v0.*",
    opts = {
      completion = {
        list = { selection = "auto_insert" },
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },

        menu = { enabled = true, border = "single" },

        documentation = {
          auto_show = true,
          window = {
            min_width = 10,
            max_width = 100,
            max_height = 30,
            border = "single",
          },
        },
        ghost_text = {
          enabled = false,
        },
      },
      signature = { enabled = false },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      appearance = {
        highlight_ns = vim.api.nvim_create_namespace("blink_cmp"),
        kind_icons = {
          Text = "󰉿",
          Method = "󰆧",
          Function = "󰊕",
          Constructor = "",
          Field = "󰜢",
          Variable = "󰀫",
          Class = "󰠱",
          Interface = "",
          Module = "",
          Property = "󰜢",
          Unit = "󰑭",
          Value = "󰎠",
          Enum = "",
          Keyword = "󰌋",
          Snippet = "",
          Color = "󰏘",
          File = "󰈙",
          Reference = "󰈇",
          Folder = "󰉋",
          EnumMember = "",
          Constant = "󰏿",
          Struct = "󰙅",
          Event = "",
          Operator = "󰆕",
          TypeParameter = "󰬛",
        },
      },
    },
    opts_extend = { "sources.default" },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true },
}

local ft_plugins = {
  elixir = require("plugins.langs.elixir"),
  go = require("plugins.langs.go"),
  markdown = require("plugins.langs.markdown").plugins,
  norg = require("plugins.langs.neorg"),
  rust = require("plugins.langs.rust"),
  typescript = require("plugins.langs.typescript"),
  yuck = require("plugins.langs.yuck"),
}

local fts = require("config.used_ft").used_ft
for ft, plugin in pairs(ft_plugins) do
  if require("utils").contains(fts, ft) then
    table.insert(plugins, plugin)
  end
end

return plugins
