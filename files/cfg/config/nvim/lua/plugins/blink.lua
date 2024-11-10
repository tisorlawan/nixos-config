return {
  {
    "rafamadriz/friendly-snippets",
    enabled = false,
  },
  {
    "hrsh7th/nvim-cmp",
    enabled = false,
  },
  {
    "saghen/blink.cmp",
    lazy = false,
    enabled = true,
    version = "v0.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- see the "default configuration" section below for full documentation on how to define
      -- your own keymap.
      -- keymap = { preset = "enter" },
      keymap = { preset = "default" },
      -- keymap = {
      --   ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      --   ["<C-e>"] = { "hide", "fallback" },
      --   ["<CR>"] = { "accept", "fallback" },
      --   ["<C-y>"] = { "accept", "fallback" },
      --
      --   ["<Tab>"] = { "snippet_forward", "fallback" },
      --   ["<S-Tab>"] = { "snippet_backward", "fallback" },
      --
      --   ["<Up>"] = { "select_prev", "fallback" },
      --   ["<Down>"] = { "select_next", "fallback" },
      --   ["<C-p>"] = { "select_prev", "fallback" },
      --   ["<C-n>"] = { "select_next", "fallback" },
      --
      --   ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      --   ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      -- },
      highlight = {
        -- sets the fallback highlight groups to nvim-cmp's highlight groups
        -- useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release, assuming themes add support
        use_nvim_cmp_as_default = true,
      },
      -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- adjusts spacing to ensure icons are aligned
      nerd_font_variant = "mono",
      -- experimental auto-brackets support
      accept = {
        auto_brackets = { enabled = true },
      },
      -- experimental signature help support
      trigger = {
        signature_help = {
          enabled = false,
          show_on_insert_on_trigger_character = false,
        },
        -- completion = {
        --   show_on_accept_on_trigger_character = false,
        --   -- when true, will show the completion window when the cursor comes after a trigger character when entering insert mode
        --   show_on_insert_on_trigger_character = false,
        -- },
      },

      fuzzy = {
        sorts = { "kind", "label", "score" },
        prebuilt_binaries = {
          -- Whether or not to automatically download a prebuilt binary from github. If this is set to `false`
          -- you will need to manually build the fuzzy binary dependencies by running `cargo build --release`
          download = true,
          -- When downloading a prebuilt binary, force the downloader to resolve this version. If this is unset
          -- then the downloader will attempt to infer the version from the checked out git tag (if any).
          --
          -- Beware that if the FFI ABI changes while tracking main then this may result in blink breaking.
          force_version = nil,
          -- When downloading a prebuilt binary, force the downloader to use this system triple. If this is unset
          -- then the downloader will attempt to infer the system triple from `jit.os` and `jit.arch`.
          -- Check the latest release for all available system triples
          --
          -- Beware that if the FFI ABI changes while tracking main then this may result in blink breaking.
          force_system_triple = nil,
        },
      },

      sources = {
        completion = {
          enabled_providers = { "lsp", "path", "snippets", "buffer" },
        },

        providers = {
          lsp = {
            name = "LSP",
            module = "blink.cmp.sources.lsp",

            --- *All* of the providers have the following options available
            --- NOTE: All of these options may be functions to get dynamic behavior
            --- See the type definitions for more information
            enabled = true, -- whether or not to enable the provider
            transform_items = nil, -- function to transform the items before they're returned
            should_show_items = true, -- whether or not to show the items
            max_items = nil, -- maximum number of items to return
            min_keyword_length = 0, -- minimum number of characters to trigger the provider
            fallback_for = {}, -- if any of these providers return 0 items, it will fallback to this provider
            score_offset = 0, -- boost/penalize the score of the items
            override = nil, -- override the source's functions
          },
          path = {
            name = "Path",
            module = "blink.cmp.sources.path",
            score_offset = 3,
            opts = {
              trailing_slash = false,
              label_trailing_slash = true,
              get_cwd = function(context)
                return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
              end,
              show_hidden_files_by_default = false,
            },
          },
          snippets = {
            name = "Snippets",
            module = "blink.cmp.sources.snippets",
            score_offset = -3,
            opts = {
              friendly_snippets = true,
              search_paths = { vim.fn.stdpath("config") .. "/snippets" },
              global_snippets = { "all" },
              extended_filetypes = {},
              ignored_filetypes = {},
            },

            --- Example usage for disabling the snippet provider after pressing trigger characters (i.e. ".")
            -- enabled = function(ctx) return ctx ~= nil and ctx.trigger.kind == vim.lsp.protocol.CompletionTriggerKind.TriggerCharacter end,
          },
          buffer = {
            name = "Buffer",
            module = "blink.cmp.sources.buffer",
            fallback_for = { "lsp" },
            score_offset = -3,
            min_keyword_length = 3,
          },
        },
      },
      windows = {
        autocomplete = {
          border = "rounded",
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          selection = "preselect",
        },
        documentation = {
          auto_show = true,
          border = "rounded",
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        },
        signature_help = {
          border = "rounded",
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
      },

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
        TypeParameter = "",
      },
    },
  },
}
