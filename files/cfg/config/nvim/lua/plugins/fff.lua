return {
  "dmtrKovalenko/fff.nvim",
  -- build = "cargo build --release",
  -- or if you are using nixos
  -- name = "fff.nvim",
  build = "nix run .#release",
  opts = {
    prompt = "> ", -- Input prompt symbol
    title = "FFF Files", -- Window title
    max_results = 60, -- Maximum search results to display
    max_threads = 8, -- Maximum threads for fuzzy search

    keymaps = {
      close = "<Esc>",
      select = "<CR>",
      select_split = "<C-s>",
      select_vsplit = "<C-v>",
      select_tab = "<C-t>",
      -- Multiple bindings supported
      move_up = { "<Up>", "<C-p>" },
      move_down = { "<Down>", "<C-n>" },
      preview_scroll_up = "<C-u>",
      preview_scroll_down = "<C-d>",
    },

    -- Highlight groups
    hl = {
      border = "FloatBorder",
      normal = "Normal",
      cursor = "CursorLine",
      matched = "IncSearch",
      title = "Title",
      prompt = "Question",
      active_file = "Visual",
      frecency = "Number",
      debug = "Comment",
    },
  },
  keys = {
    {
      "<c-p>",
      function()
        require("fff").find_files() -- or find_in_git_root() if you only want git files
      end,
      desc = "Open file picker",
    },
  },
}
