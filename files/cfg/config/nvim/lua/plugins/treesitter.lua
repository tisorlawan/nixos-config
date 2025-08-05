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
        "markdown_inline",
        "vim",
        "vimdoc",
      },
      auto_install = false,
      ignore_install = { "gitcommit" },
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
