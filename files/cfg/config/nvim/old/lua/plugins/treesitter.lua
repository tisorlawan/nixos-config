local utils = require("utils")
local used_ft = require("plugins.lsp.config").used_ft

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      { "yioneko/nvim-yati", event = { "BufReadPost", "BufNewFile" } },
      { "nvim-treesitter/playground" },
      { "windwp/nvim-ts-autotag" },
    },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "lua",
        "luadoc",
        "markdown",
        "vim",
        "vimdoc",
        "markdown_inline",
        "markdown",
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "ruby", "elixir" },
      },

      indent = {
        enable = true,
        disable = {
          "python",
          "css",
          "rust",
          "lua",
          "javascript",
          "tsx",
          "typescript",
          "toml",
          "json",
          "c",
          "heex",
        },
      },
      yati = {
        enable = true,
        disable = { "rust" },
        default_lazy = true,
        default_fallback = "auto",
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.install").prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup(opts)

      if utils.contains(used_ft, "blade") then
        local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
        parser_config.blade = {
          install_info = {
            url = "https://github.com/EmranMR/tree-sitter-blade",
            files = { "src/parser.c" },
            branch = "main",
          },
          filetype = "blade",
        }

        vim.cmd([[
          augroup BladeFiltypeRelated
            au BufNewFile,BufRead *.blade.php set ft=blade
          augroup END
        ]])
      end
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup({
        aliases = {
          ["heex"] = "html",
        },
      })
    end,
    event = { "BufReadPost", "BufNewFile" },
  },
}
