return {
  "mikavilpas/yazi.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- stylua: ignore
  keys = {
    { "<m-o>", function() require("yazi").yazi() end, desc = "Open the file manager", },
    { "<leader>yw", "<cmd>Yazi cwd<cr>", desc = "Open the file manager in nvim's working directory", },
    { "<m-m>", "<cmd>Yazi toggle<cr>", desc = "Resume the last yazi session", },
  },
  ---@type YaziConfig
  opts = {
    open_for_directories = false,
    yazi_floating_window_border = "single",
  },
}
