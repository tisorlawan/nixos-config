local utils = require("utils")
local used_ft = {}
local fpath = vim.fn.stdpath("config") .. "/ft"

if utils.file_exists(fpath) then
  for line in io.lines(fpath) do
    local trimmed_line = utils.trim(line)
    if trimmed_line:len() > 0 and trimmed_line:sub(1, 1) ~= "#" and trimmed_line:sub(1, 4) ~= "vim:" then
      table.insert(used_ft, trimmed_line)
    end
  end
end

local config = {
  blade = {
    formatters = { "blade-formatter" },
  },
  c = {
    formatters = { "clang_format" },
    servers = { "clangd" },
  },
  css = {
    servers = { "tailwindcss" },
    linters = { "stylelint" },
  },
  dockerfile = {
    linters = { "hadolint" },
  },
  go = {
    formatters = { "gofumpt", "goimports", "golines" },
    servers = { "gopls" },
  },
  haskell = {
    formatters = { "ormolu" },
    servers = { "hls" },
  },
  html = {
    servers = { "html" },
    formatters = { "prettierd" },
    linters = { "htmlhint" },
  },
  javascript = {
    formatters = { "biome" },
  },
  json = {
    formatters = { "biome" },
    linters = { "jsonlint" },
    -- servers = { "jsonls" },
  },
  lua = {
    formatters = { "stylua" },
    -- servers = { "lua_ls" },
  },
  markdown = {
    linters = { "markdownlint" },
    formatters = { "prettierd" },
    servers = { "marksman" },
  },
  nix = {
    servers = { "nil_ls" },
    formatters = { "nixpkgs_fmt" },
  },
  python = {
    formatters = { "ruff_format", "ruff_fix" },
    servers = { "pyright", "ruff" },
  },
  php = {
    formatters = { "php_cs_fixer" },
    servers = { "phpactor", "html" },
  },
  rust = {
    servers = { "rust_analyzer" },
    -- formatters = { "rustfmt", "leptosfmt" },
    formatters = { "rustfmt" },
  },
  sh = {
    servers = { "bashls" },
    formatters = { "shfmt" },
  },
  templ = {
    formatters = { "templ" },
    servers = { "templ" },
  },
  toml = {
    formatters = { "taplo" },
  },
  typescript = {
    formatters = { "prettierd" },
    servers = { "ts_ls", "eslint" },
  },
  typescriptreact = {
    formatters = { "prettierd" },
    servers = { "ts_ls", "eslint" },
  },
  zig = {
    formatters = { "zigfmt" },
    servers = { "zls" },
  },
}

local formatters_to_mason = {
  clang_format = "clang-format",
  ruff_fix = "ruff",
  ruff_format = "ruff",
  nixpkgs_fmt = "nixpkgs-fmt",
  php_cs_fixer = "php-cs-fixer",
}

local mason_lspserver = {}
for _, ft in pairs(used_ft) do
  for _, name in pairs((config[ft] or {}).servers or {}) do
    table.insert(mason_lspserver, name)
  end
end

local formatters_by_ft = {}
for _, ft in pairs(used_ft) do
  local cfg = (config[ft] or {}).formatters
  if cfg ~= nil then
    formatters_by_ft[ft] = cfg
  end
end

local mason_formatter_install = {}

for _, names in pairs(formatters_by_ft) do
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

local linters_by_ft = {}
for _, ft in pairs(used_ft) do
  local cfg = (config[ft] or {}).linters
  if cfg ~= nil then
    linters_by_ft[ft] = cfg
  end
end

local mason_linter_install = {}

local linters_to_mason = {}
for _, names in pairs(linters_by_ft) do
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
    vnmap("<leader>la", "<cmd>lua require('fzf-lua').lsp_code_actions()<cr>", "Code action (FZF Lua)")
    vnmap("<leader>lA", vim.lsp.buf.code_action, "Code action")
  else
    vnmap("<leader>la", vim.lsp.buf.code_action, "Code action")
  end
end

local M = {
  used_ft = used_ft,
  formatters_by_ft = formatters_by_ft,
  mason_formatter_install = mason_formatter_install,
  linters_by_ft = linters_by_ft,
  mason_linter_install = mason_linter_install,
  mason_lspserver = mason_lspserver,
  setup_lsp_keymaps = setup_lsp_keymaps,
  config = {
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
  },
  on_attach = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc" -- Enable completion triggered by <c-x><c-o>
    setup_lsp_keymaps(ev.buf)

    -- disable semantic tokens
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client ~= nil then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
}
return M
