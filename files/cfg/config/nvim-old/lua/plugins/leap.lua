return {
  "https://codeberg.org/andyg/leap.nvim",
  keys = {
    { "s", "<Plug>(leap-forward)", mode = { "n", "x", "o" }, desc = "leap forward to" },
    { "S", "<Plug>(leap-backward)", mode = { "n", "x", "o" }, desc = "leap backward to" },
    { "x", "<Plug>(leap-forward-till)", mode = { "x", "o" }, desc = "leap forward till" },
    { "X", "<Plug>(leap-backward-till)", mode = { "x", "o" }, desc = "leap backward till" },
    { "gs", "<Plug>(leap-from-window)", mode = { "n", "x", "o" }, desc = "leap from window" },
  },
  opts = {
    safe_labels = "tyuofghjklvbn",
    labels = "sfnjklhowembuyvrgtqpcxz/SFNJKLHOWEIMBUYVRGTAQPCXZ",
  },
  dependencies = {
    "tpope/vim-repeat",
  },
}
