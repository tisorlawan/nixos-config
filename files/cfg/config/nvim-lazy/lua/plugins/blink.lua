return {
  {
    "rafamadriz/friendly-snippets",
    enabled = false,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "onsails/lspkind.nvim",
    },
    enabled = false,
    opts = function(_, opts)
      local cmp = require("cmp")
      local lspkind = require("lspkind")

      opts.window = {
        completion = cmp.config.window.bordered({ border = "single" }),
        documentation = cmp.config.window.bordered({ border = "single" }),
      }

      opts.formatting = {
        format = function(entry, item)
          local fmt = lspkind.cmp_format({
            mode = "symbol",
            before = function(_, vim_item)
              vim_item.menu = nil
              return vim_item
            end,
          })
          return fmt(entry, item)
        end,
      }
    end,
  },
  {
    "saghen/blink.cmp",
    lazy = false,
    enabled = true,
    version = "v0.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      windows = {
        documentation = {
          auto_show = true,
          border = "single",
        },
        autocomplete = {
          selection = "auto_insert",
          border = "single",
        },
      },
      accept = { auto_brackets = { enabled = true } },
      trigger = { signature_help = { enabled = false } },
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
