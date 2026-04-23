local shared = require 'shared'

local lsp_servers = {
  bashls = {
    cmd = { 'bash-language-server', 'start' },
    filetypes = { 'bash', 'sh' },
    root_markers = { '.git' },
  },
  basedpyright = {
    cmd = { 'basedpyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
    settings = {
      basedpyright = {
        analysis = {
          autoImportCompletions = false,
          autoSearchPaths = false,
          useLibraryCodeForTypes = false,
          diagnosticMode = 'openFilesOnly',
        },
      },
    },
  },
  pyright = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
    settings = {
      pyright = {
        analysis = {
          autoImportCompletions = false,
          autoSearchPaths = false,
          useLibraryCodeForTypes = false,
          diagnosticMode = 'openFilesOnly',
        },
      },
    },
  },
  clangd = {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
    root_markers = { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', '.git' },
  },
  eslint = {
    cmd = { 'vscode-eslint-language-server', '--stdio' },
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue', 'svelte', 'astro' },
    root_markers = { '.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.json', 'eslint.config.js', 'eslint.config.mjs', 'package.json' },
  },
  gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.mod', 'go.work', '.git' },
  },
  html = {
    cmd = { 'vscode-html-language-server', '--stdio' },
    filetypes = { 'html', 'php' },
    root_markers = { 'package.json', '.git' },
    init_options = {
      provideFormatter = true,
      embeddedLanguages = { css = true, javascript = true },
      configurationSection = { 'html', 'css', 'javascript' },
    },
  },
  lua_ls = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.stylua.toml', 'stylua.toml', '.git' },
    settings = {
      Lua = {
        diagnostics = { globals = { 'vim' } },
        workspace = {
          library = vim.api.nvim_get_runtime_file('', true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  },
  marksman = {
    cmd = { 'marksman', 'server' },
    filetypes = { 'markdown' },
    root_markers = { '.marksman.toml', '.git' },
  },
  nil_ls = {
    cmd = { 'nil' },
    filetypes = { 'nix' },
    root_markers = { 'flake.nix', '.git' },
  },
  phpactor = {
    cmd = { 'phpactor', 'language-server' },
    filetypes = { 'php' },
    root_markers = { 'composer.json', '.git' },
  },
  ruff = {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  },
  rust_analyzer = {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', 'rust-project.json' },
    settings = {
      ['rust-analyzer'] = {
        completion = {
          -- callable = {
          --   snippets = 'none',
          -- },
        },
      },
    },
  },
  ts_ls = {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
    init_options = {
      hostInfo = 'neovim',
      plugins = {
        {
          name = '@effect/language-service',
          location = vim.fn.getcwd() .. '/node_modules',
        },
      },
      preferences = {
        includePackageJsonAutoImports = 'on',
      },
    },
  },
  zls = {
    cmd = { 'zls' },
    filetypes = { 'zig' },
    root_markers = { 'build.zig', 'zls.json', '.git' },
  },
}

local function setup_lsp_keymaps(bufnr)
  local function map(key, func, desc)
    vim.keymap.set('n', key, func, { buffer = bufnr, desc = desc, silent = true })
  end

  map('gd', vim.lsp.buf.definition, 'Goto definition')
  map('gD', vim.lsp.buf.declaration, 'Goto declaration')
  map('K', function()
    vim.lsp.buf.hover { border = 'single' }
  end, 'Hover')
  map('<leader>k', function()
    vim.lsp.buf.signature_help { border = 'single' }
  end, 'Signature help')
  map('[d', function()
    vim.diagnostic.jump {
      count = -1,
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          border = 'single',
          scope = 'cursor',
          focus = false,
        }
      end,
    }
  end, 'Prev diagnostic')
  map(']d', function()
    vim.diagnostic.jump {
      count = 1,
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          border = 'single',
          scope = 'cursor',
          focus = false,
        }
      end,
    }
  end, 'Next diagnostic')
  map('<leader>ci', vim.lsp.buf.incoming_calls, 'Incoming calls')
  map('<leader>co', vim.lsp.buf.outgoing_calls, 'Outgoing calls')
end

local function on_attach(client, bufnr)
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  setup_lsp_keymaps(bufnr)
  -- client.server_capabilities.semanticTokensProvider = nil
end

local function setup_diagnostics()
  vim.diagnostic.config {
    virtual_text = false,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = shared.icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN] = shared.icons.diagnostics.Warn,
        [vim.diagnostic.severity.HINT] = shared.icons.diagnostics.Hint,
        [vim.diagnostic.severity.INFO] = shared.icons.diagnostics.Info,
      },
    },
    float = {
      border = 'single',
      header = 'Diagnostics:',
      prefix = function(diagnostic, index)
        local severity = vim.diagnostic.severity[diagnostic.severity]
        local level = severity:sub(1, 1) .. severity:sub(2):lower()
        return string.format('%d. ', index), 'DiagnosticFloating' .. level
      end,
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  }
end

local function create_lsp_info_command()
  vim.api.nvim_create_user_command('LspInfo', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients { bufnr = bufnr }
    local enabled = vim.tbl_keys(lsp_servers)
    table.sort(enabled)

    local lines = {
      string.rep('=', 60),
      'vim.lsp',
      '',
      'Active Clients:',
    }

    if #clients == 0 then
      table.insert(lines, '  (none)')
    else
      for _, client in ipairs(clients) do
        table.insert(lines, string.format('  - %s (id=%d, root=%s)', client.name, client.id, client.root_dir or '?'))
      end
    end

    table.insert(lines, '')
    table.insert(lines, 'Configured Servers:')

    for _, name in ipairs(enabled) do
      local config = lsp_servers[name]
      local executable = config.cmd and config.cmd[1] or '?'
      local installed = vim.fn.executable(executable) == 1
      table.insert(lines, string.format('  %s %s%s', installed and '+' or '-', name, installed and '' or ' (not installed)'))
      table.insert(lines, string.format('      cmd: %s', table.concat(config.cmd or {}, ' ')))
      table.insert(lines, string.format('      filetypes: %s', table.concat(config.filetypes or {}, ', ')))
      table.insert(lines, string.format('      root_markers: %s', table.concat(config.root_markers or {}, ', ')))

      if config.settings then
        for _, line in ipairs(vim.split(vim.inspect(config.settings), '\n')) do
          table.insert(lines, '      ' .. line)
        end
      end

      if config.init_options then
        table.insert(lines, '      init_options:')
        for _, line in ipairs(vim.split(vim.inspect(config.init_options), '\n')) do
          table.insert(lines, '        ' .. line)
        end
      end
    end

    vim.cmd.tabnew()
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].swapfile = false
    vim.api.nvim_buf_set_name(buf, '[LspInfo]')
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.keymap.set('n', 'q', '<cmd>tabclose<cr>', { buffer = buf, silent = true })
  end, { force = true })
end

local function create_lsp_restart_command()
  vim.api.nvim_create_user_command('LspRestart', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients { bufnr = bufnr }
    local names = {}

    for _, client in ipairs(clients) do
      table.insert(names, client.name)
      vim.lsp.stop(client.id)
    end

    vim.defer_fn(function()
      for _, name in ipairs(names) do
        vim.lsp.enable(name, { bufnr = bufnr })
        vim.lsp.enable 'filepaths_ls'
      end

      vim.notify(string.format('Restarted %d LSP client(s): %s', #names, table.concat(names, ', ')), vim.log.levels.INFO)
    end, 500)
  end, { force = true })
end

local function setup()
  local used_filetypes = shared.get_used_filetypes()

  setup_diagnostics()
  vim.keymap.set('n', '<leader>ud', function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    require('lualine').refresh()
  end, { desc = 'Toggle diagnostics' })
  vim.keymap.set('n', 'gl', function()
    vim.diagnostic.open_float { border = 'single' }
  end, { desc = 'Show line diagnostics' })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspAttach', { clear = true }),
    callback = function(event)
      on_attach(vim.lsp.get_client_by_id(event.data.client_id), event.buf)
    end,
  })

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  vim.lsp.config('*', { capabilities = capabilities })

  local servers_to_enable = {}
  for _, filetype in ipairs(used_filetypes.used_ft) do
    for _, server in ipairs((used_filetypes.config[filetype] or {}).servers or {}) do
      if lsp_servers[server] and not vim.tbl_contains(servers_to_enable, server) then
        table.insert(servers_to_enable, server)
      end
    end
  end

  for _, server in ipairs(servers_to_enable) do
    vim.lsp.config(server, lsp_servers[server])
  end

  vim.lsp.enable(servers_to_enable)
  vim.lsp.enable 'filepaths_ls'
  create_lsp_info_command()
  create_lsp_restart_command()
end

setup()
