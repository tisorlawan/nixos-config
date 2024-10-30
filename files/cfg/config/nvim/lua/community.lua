---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.laravel" },
  { import = "astrocommunity.pack.blade" },
  { import = "astrocommunity.pack.php" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.python-ruff" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.zig" },
  { import = "astrocommunity.pack.haskell" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.xml" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.tailwindcss" },

  { import = "astrocommunity.colorscheme.kanagawa-nvim" },
  { import = "astrocommunity.colorscheme.catppuccin" },

  { import = "astrocommunity.motion.leap-nvim" },

  { import = "astrocommunity.quickfix.nvim-bqf" },


  {"mrcjkb/neotest-haskell", enabled = false}

  -- import/override with your plugins folder
}
