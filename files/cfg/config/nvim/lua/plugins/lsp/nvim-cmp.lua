return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    -- Snippet Engine & its associated nvim-cmp source
    {
      "L3MON4D3/LuaSnip",
      build = (function()
        -- Build Step is needed for regex support in snippets.
        -- This step is not supported in many windows environments.
        -- Remove the below condition to re-enable on windows.
        if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
          return
        end
        return "make install_jsregexp"
      end)(),
      dependencies = {
        -- `friendly-snippets` contains a variety of premade snippets.
        --    See the README about individual language/framework/plugin snippets:
        --    https://github.com/rafamadriz/friendly-snippets
        -- {
        --   "rafamadriz/friendly-snippets",
        --   config = function()
        --     require("luasnip.loaders.from_vscode").lazy_load()
        --   end,
        -- },
      },
    },
    "saadparwaiz1/cmp_luasnip",

    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",

    "onsails/lspkind.nvim",
    { "js-everts/cmp-tailwind-colors", opts = {} },
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
      },
    },
  },
  config = function()
    local cmp = require("cmp")
    local lspkind = require("lspkind")
    local luasnip = require("luasnip")

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
      window = {
        completion = cmp.config.window.bordered({ border = "single" }),
        documentation = cmp.config.window.bordered({ border = "single" }),
      },
      -- completion = {
      --   autocomplete = false,
      -- },
      mapping = {
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      },

      sources = cmp.config.sources({
        { name = "lazydev", group_index = 0 },
        { name = "path", priority = 1200 },
        -- { name = "codeium", priority = 1100 },
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 750 },
        { name = "buffer", priority = 500, keyword_length = 3 },
      }),
      ---@diagnostic disable-next-line: missing-fields
      formatting = {
        format = function(entry, item)
          local fmt = lspkind.cmp_format({
            mode = "symbol",
            maxwidth = 50,
            ellipsis_char = "...",
            symbol_map = { Codeium = "" },

            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            before = function(_, vim_item)
              vim_item.menu = nil
              return vim_item
            end,
          })
          if item.kind == "Color" then
            local vim_item = require("cmp-tailwind-colors").format(entry, item)
            if item.kind == "Color" then
              return fmt(entry, vim_item)
            end
            vim_item.menu = nil
            return vim_item
          end
          item.menu = nil
          return fmt(entry, item)
        end,
      },
    })

    -- -- See `:help cmp`
    -- local cmp = require 'cmp'
    -- local luasnip = require 'luasnip'
    -- luasnip.config.setup {}

    -- cmp.setup {
    --   snippet = {
    --     expand = function(args)
    --       luasnip.lsp_expand(args.body)
    --     end,
    --   },
    --   completion = { completeopt = 'menu,menuone,noinsert' },

    --   -- For an understanding of why these mappings were
    --   -- chosen, you will need to read `:help ins-completion`
    --   --
    --   -- No, but seriously. Please read `:help ins-completion`, it is really good!
    --   mapping = cmp.mapping.preset.insert {
    --     -- Select the [n]ext item
    --     ['<C-n>'] = cmp.mapping.select_next_item(),
    --     -- Select the [p]revious item
    --     ['<C-p>'] = cmp.mapping.select_prev_item(),

    --     -- Scroll the documentation window [b]ack / [f]orward
    --     ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    --     ['<C-f>'] = cmp.mapping.scroll_docs(4),

    --     -- Accept ([y]es) the completion.
    --     --  This will auto-import if your LSP supports it.
    --     --  This will expand snippets if the LSP sent a snippet.
    --     ['<C-y>'] = cmp.mapping.confirm { select = true },

    --     -- If you prefer more traditional completion keymaps,
    --     -- you can uncomment the following lines
    --     --['<CR>'] = cmp.mapping.confirm { select = true },
    --     --['<Tab>'] = cmp.mapping.select_next_item(),
    --     --['<S-Tab>'] = cmp.mapping.select_prev_item(),

    --     -- Manually trigger a completion from nvim-cmp.
    --     --  Generally you don't need this, because nvim-cmp will display
    --     --  completions whenever it has completion options available.
    --     ['<C-Space>'] = cmp.mapping.complete {},

    --     -- Think of <c-l> as moving to the right of your snippet expansion.
    --     --  So if you have a snippet that's like:
    --     --  function $name($args)
    --     --    $body
    --     --  end
    --     --
    --     -- <c-l> will move you to the right of each of the expansion locations.
    --     -- <c-h> is similar, except moving you backwards.
    --     -- ['<C-l>'] = cmp.mapping(function()
    --     --   if luasnip.expand_or_locally_jumpable() then
    --     --     luasnip.expand_or_jump()
    --     --   end
    --     -- end, { 'i', 's' }),
    --     -- ['<C-h>'] = cmp.mapping(function()
    --     --   if luasnip.locally_jumpable(-1) then
    --     --     luasnip.jump(-1)
    --     --   end
    --     -- end, { 'i', 's' }),

    --     -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
    --     --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    --   },
    --   sources = {
    --     { name = 'nvim_lsp' },
    --     { name = 'luasnip' },
    --     { name = 'path' },
    --   },
    -- }
  end,
}
