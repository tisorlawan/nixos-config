return {
  "google/executor.nvim",
  dependencies = "MunifTanjim/nui.nvim",
  opts = {
    split = {
      size = math.floor(vim.o.columns * 2 / 5),
    },
    preset_commands = {
      ["lie"] = {
        {
          cmd = function()
            return "cargo lrun --quiet"
          end,
        },
      },
    },
  },
  keys = {
    { "<leader>rr", ":ExecutorRun<CR>", desc = "Executor Run", silent = true },
    { "<leader>re", ":ExecutorSetCommand<CR>", desc = "Executor Set Command", silent = true },
    { "<leader>rp", ":ExecutorToggleDetail<CR>", desc = "Executor Toggle Detail", silent = true },
    { "<leader>rw", ":ExecutorShowPresets<CR>", desc = "Executor Show Presets", silent = true },
  },
  cmd = {
    "ExecutorRun",
    "ExecutorSetCommand",
    "ExecutorShowDetail",
    "ExecutorHideDetail",
    "ExecutorToggleDetail",
    "ExecutorSwapToSplit",
    "ExecutorSwapToPopup",
    "ExecutorToggleDetail",
    "ExecutorReset",
  },
}
