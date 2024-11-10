-- -- since this is just an example spec, don't actually load anything here and return an empty spec
-- -- stylua: ignore
-- if true then return {} end

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  -- add gruvbox
  {
    "rebelot/kanagawa.nvim",
    priority = 0,
    enabled = true,
    config = function()
      require("kanagawa").setup({
        undercurl = true,
        commentStyle = { italic = false },
        keywordStyle = { italic = false },
        statementStyle = { bold = false },
        transparent = vim.g.transparent,
        dimInactive = false,
        terminalColors = true,
      })
    end,
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme can be a string like `catppuccin` or a function that will load the colorscheme
      ---@type string|fun()
      colorscheme = "tokyonight-night",
      -- colorscheme = "jellybeans",
      -- colorscheme = "kanagawa",
      -- load the default settings
      defaults = {
        autocmds = true, -- lazyvim.config.autocmds
        keymaps = true, -- lazyvim.config.keymaps
        -- lazyvim.config.options can't be configured here since that's loaded before lazyvim setup
        -- if you want to disable loading options, add `package.loaded["lazyvim.config.options"] = true` to the top of your init.lua
      },
      news = {
        -- When enabled, NEWS.md will be shown when changed.
        -- This only contains big new features and breaking changes.
        lazyvim = true,
        -- Same but for Neovim's news.txt
        neovim = false,
      },
      -- icons used by other plugins
      -- stylua: ignore
      icons = {
        misc = {
          dots = "󰇘",
        },
        ft = {
          octo = "",
        },
        dap = {
          Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
          Breakpoint          = " ",
          BreakpointCondition = " ",
          BreakpointRejected  = { " ", "DiagnosticError" },
          LogPoint            = ".>",
        },
        diagnostics = {
          Error = " ",
          Warn  = " ",
          Hint  = " ",
          Info  = " ",
        },
        git = {
          added    = " ",
          modified = " ",
          removed  = " ",
        },
        kinds = {
          Array         = " ",
          Boolean       = "󰨙 ",
          Class         = " ",
          Codeium       = "󰘦 ",
          Color         = " ",
          Control       = " ",
          Collapsed     = " ",
          Constant      = "󰏿 ",
          Constructor   = " ",
          Copilot       = " ",
          Enum          = " ",
          EnumMember    = " ",
          Event         = " ",
          Field         = " ",
          File          = " ",
          Folder        = " ",
          Function      = "󰊕 ",
          Interface     = " ",
          Key           = " ",
          Keyword       = " ",
          Method        = "󰊕 ",
          Module        = " ",
          Namespace     = "󰦮 ",
          Null          = " ",
          Number        = "󰎠 ",
          Object        = " ",
          Operator      = " ",
          Package       = " ",
          Property      = " ",
          Reference     = " ",
          Snippet       = " ",
          String        = " ",
          Struct        = "󰆼 ",
          TabNine       = "󰏚 ",
          Text          = " ",
          TypeParameter = " ",
          Unit          = " ",
          Value         = " ",
          Variable      = "󰀫 ",
        },
      },
      ---@type table<string, string[]|boolean>?
      kind_filter = {
        default = {
          "Class",
          "Constructor",
          "Enum",
          "Field",
          "Function",
          "Interface",
          "Method",
          "Module",
          "Namespace",
          "Package",
          "Property",
          "Struct",
          "Trait",
        },
        markdown = false,
        help = false,
        -- you can specify a different filter for each filetype
        lua = {
          "Class",
          "Constructor",
          "Enum",
          "Field",
          "Function",
          "Interface",
          "Method",
          "Module",
          "Namespace",
          -- "Package", -- remove package since luals uses it for control flow structures
          "Property",
          "Struct",
          "Trait",
        },
      },
    },
  },

  -- -- change trouble config
  -- {
  --   "folke/trouble.nvim",
  --   -- opts will be merged with the parent spec
  --   opts = { use_diagnostic_signs = true },
  -- },
  --
  -- -- disable trouble
  -- { "folke/trouble.nvim", enabled = false },
  --
  -- -- override nvim-cmp and add cmp-emoji
  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = { "hrsh7th/cmp-emoji" },
  --   ---@param opts cmp.ConfigSchema
  --   opts = function(_, opts)
  --     table.insert(opts.sources, { name = "emoji" })
  --   end,
  -- },
  --
  -- -- change some telescope options and a keymap to browse plugin files
  -- {
  --   "nvim-telescope/telescope.nvim",
  --   keys = {
  --     -- add a keymap to browse plugin files
  --     -- stylua: ignore
  --     {
  --       "<leader>fp",
  --       function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
  --       desc = "Find Plugin File",
  --     },
  --   },
  --   -- change some options
  --   opts = {
  --     defaults = {
  --       layout_strategy = "horizontal",
  --       layout_config = { prompt_position = "top" },
  --       sorting_strategy = "ascending",
  --       winblend = 0,
  --     },
  --   },
  -- },
  --
  -- -- add pyright to lspconfig
  -- {
  --   "neovim/nvim-lspconfig",
  --   ---@class PluginLspOpts
  --   opts = {
  --     ---@type lspconfig.options
  --     servers = {
  --       -- pyright will be automatically installed with mason and loaded with lspconfig
  --       pyright = {},
  --     },
  --   },
  -- },
  --
  -- -- add tsserver and setup with typescript.nvim instead of lspconfig
  -- {
  --   "neovim/nvim-lspconfig",
  --   dependencies = {
  --     "jose-elias-alvarez/typescript.nvim",
  --     init = function()
  --       require("lazyvim.util").lsp.on_attach(function(_, buffer)
  --         -- stylua: ignore
  --         vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
  --         vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
  --       end)
  --     end,
  --   },
  --   ---@class PluginLspOpts
  --   opts = {
  --     ---@type lspconfig.options
  --     servers = {
  --       -- tsserver will be automatically installed with mason and loaded with lspconfig
  --       tsserver = {},
  --     },
  --     -- you can do any additional lsp server setup here
  --     -- return true if you don't want this server to be setup with lspconfig
  --     ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
  --     setup = {
  --       -- example to setup with typescript.nvim
  --       tsserver = function(_, opts)
  --         require("typescript").setup({ server = opts })
  --         return true
  --       end,
  --       -- Specify * to use this function as a fallback for any server
  --       -- ["*"] = function(server, opts) end,
  --     },
  --   },
  -- },
  --
  -- -- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
  -- -- treesitter, mason and typescript.nvim. So instead of the above, you can use:
  -- { import = "lazyvim.plugins.extras.lang.typescript" },
  --
  -- -- add more treesitter parsers
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   opts = {
  --     ensure_installed = {
  --       "bash",
  --       "html",
  --       "javascript",
  --       "json",
  --       "lua",
  --       "markdown",
  --       "markdown_inline",
  --       "python",
  --       "query",
  --       "regex",
  --       "tsx",
  --       "typescript",
  --       "vim",
  --       "yaml",
  --     },
  --   },
  -- },
  --
  -- -- since `vim.tbl_deep_extend`, can only merge tables and not lists, the code above
  -- -- would overwrite `ensure_installed` with the new value.
  -- -- If you'd rather extend the default config, use the code below instead:
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   opts = function(_, opts)
  --     -- add tsx and treesitter
  --     vim.list_extend(opts.ensure_installed, {
  --       "tsx",
  --       "typescript",
  --     })
  --   end,
  -- },
  --
  -- -- the opts function can also be used to change the default opts:
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   event = "VeryLazy",
  --   opts = function(_, opts)
  --     table.insert(opts.sections.lualine_x, {
  --       function()
  --         return "😄"
  --       end,
  --     })
  --   end,
  -- },
  --
  -- -- or you can return new options to override all the defaults
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   event = "VeryLazy",
  --   opts = function()
  --     return {
  --       --[[add your custom lualine config here]]
  --     }
  --   end,
  -- },
  --
  -- -- use mini.starter instead of alpha
  -- { import = "lazyvim.plugins.extras.ui.mini-starter" },
  --
  -- -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  -- { import = "lazyvim.plugins.extras.lang.json" },
  --
  -- -- add any tools you want to have installed below
  -- {
  --   "williamboman/mason.nvim",
  --   opts = {
  --     ensure_installed = {
  --       "stylua",
  --       "shellcheck",
  --       "shfmt",
  --       "flake8",
  --     },
  --   },
  -- },
}
