return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  dependencies = {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<Leader>fu"] = { "<cmd>UndotreeToggle<CR>", desc = "Find undotree" },
        },
      },
    },
  },
}
