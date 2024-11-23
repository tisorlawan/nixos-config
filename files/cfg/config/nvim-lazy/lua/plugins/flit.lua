local keys = {}
for _, key in ipairs({ "f", "F", "t", "T" }) do
  keys[key] = { key, desc = key }
end

return {
  "ggandor/flit.nvim",
  opts = { labeled_modes = "nx" },
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    { "ggandor/leap.nvim", dependencies = { "tpope/vim-repeat" } },
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = keys,
          x = keys,
          o = keys,
        },
      },
    },
  },
}
