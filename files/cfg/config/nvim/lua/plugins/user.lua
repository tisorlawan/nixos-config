return {
  {
    "rebelot/heirline.nvim",
    optional = true,
    opts = function(_, opts) opts.statusline = nil end,
  },
   -- restore last position
  { "farmergreg/vim-lastplace" },
  require "plugins.dirvish",
  require "plugins.user.treesitter",
  require "plugins.user.markdown".plugins,
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        "<Leader>e",
        ":Neotree reveal<Cr>",
        desc = "Neotree toggle",
        silent = true,
      },
    },
    opts = function(_, opts)
      opts.filesystem = {
        hijack_netrw_behavior = "disabled",
        follow_current_file = {
          enabled = false,
        },
      }
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.telescope"(plugin, opts)

      function vim.getVisualSelection()
        vim.cmd 'noau normal! "vy"'
        local text = vim.fn.getreg "v"
        vim.fn.setreg("v", {})

        text = string.gsub(text, "\n", "")
        if #text > 0 then
          return text
        else
          return ""
        end
      end

      local keymap = vim.keymap.set
      local tb = require "telescope.builtin"

      opts = { noremap = true, silent = true }
      keymap("v", "<space>S", function()
        local text = vim.getVisualSelection()
        tb.current_buffer_fuzzy_find { default_text = text }
      end, { noremap = true, silent = true, desc = "Search current buffer" })

      keymap("v", "<space>s", function()
        local text = vim.getVisualSelection()
        tb.live_grep { default_text = text }
      end, { noremap = true, silent = true, desc = "Search all files" })

      keymap("n", "<C-p>", ":Telescope find_files<CR>", opts)
      keymap("n", "<C-n>", ":Telescope buffers<CR>", opts)
    end,
  },
  {
    "wintermute-cell/gitignore.nvim",
    cmd = "Gitignore",
  },
  require "plugins.user.arrow",
  require "plugins.user.lualine",
  require "plugins.user.flit",
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
  {
    "smoka7/multicursors.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "smoka7/hydra.nvim" },
    opts = {},
    keys = {
      {
        mode = { "v", "n" },
        "<Leader>m",
        "<Cmd>MCstart<CR>",
        desc = "Create a selection for word under the cursor",
      },
    },
  },
}

-- ---@type LazySpec
-- return {
--
--   -- == Examples of Adding Plugins ==
--
--   "andweeb/presence.nvim",
--   {
--     "ray-x/lsp_signature.nvim",
--     event = "BufRead",
--     config = function() require("lsp_signature").setup() end,
--   },
--
--   -- == Examples of Overriding Plugins ==
--
--   -- customize alpha options
--   {
--     "goolord/alpha-nvim",
--     opts = function(_, opts)
--       -- customize the dashboard header
--       opts.section.header.val = {
--         " █████  ███████ ████████ ██████   ██████",
--         "██   ██ ██         ██    ██   ██ ██    ██",
--         "███████ ███████    ██    ██████  ██    ██",
--         "██   ██      ██    ██    ██   ██ ██    ██",
--         "██   ██ ███████    ██    ██   ██  ██████",
--         " ",
--         "    ███    ██ ██    ██ ██ ███    ███",
--         "    ████   ██ ██    ██ ██ ████  ████",
--         "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
--         "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
--         "    ██   ████   ████   ██ ██      ██",
--       }
--       return opts
--     end,
--   },
--
--   -- You can disable default plugins as follows:
--   { "max397574/better-escape.nvim", enabled = false },
--
--   -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
--   {
--     "L3MON4D3/LuaSnip",
--     config = function(plugin, opts)
--       require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
--       -- add more custom luasnip configuration such as filetype extend or custom snippets
--       local luasnip = require "luasnip"
--       luasnip.filetype_extend("javascript", { "javascriptreact" })
--     end,
--   },
--
--   {
--     "windwp/nvim-autopairs",
--     config = function(plugin, opts)
--       require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
--       -- add more custom autopairs configuration such as custom rules
--       local npairs = require "nvim-autopairs"
--       local Rule = require "nvim-autopairs.rule"
--       local cond = require "nvim-autopairs.conds"
--       npairs.add_rules(
--         {
--           Rule("$", "$", { "tex", "latex" })
--             -- don't add a pair if the next character is %
--             :with_pair(cond.not_after_regex "%%")
--             -- don't add a pair if  the previous character is xxx
--             :with_pair(
--               cond.not_before_regex("xxx", 3)
--             )
--             -- don't move right when repeat character
--             :with_move(cond.none())
--             -- don't delete if the next character is xx
--             :with_del(cond.not_after_regex "xx")
--             -- disable adding a newline when you press <cr>
--             :with_cr(cond.none()),
--         },
--         -- disable for .vim files, but it work for another filetypes
--         Rule("a", "a", "-vim")
--       )
--     end,
--   },
-- }
