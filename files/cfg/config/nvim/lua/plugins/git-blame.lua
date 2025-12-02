return {
  "f-person/git-blame.nvim",
  -- load the plugin at startup
  event = "VeryLazy",
  keys = {
    { "<leader>gbo", "<cmd>GitBlameOpenCommitURL<cr>", desc = "Open blame commit URL" },
    { "<leader>gbb", "<cmd>GitBlameToggle<cr>", desc = "Toggle git blame" },
    { "<leader>gbe", "<cmd>GitBlameEnable<cr>", desc = "Enable git blame" },
    { "<leader>gbd", "<cmd>GitBlameDisable<cr>", desc = "Disable git blame" },
    { "<leader>gbs", "<cmd>GitBlameCopySHA<cr>", desc = "Copy blame SHA" },
    { "<leader>gbc", "<cmd>GitBlameCopyCommitURL<cr>", desc = "Copy blame commit URL" },
    { "<leader>gbp", "<cmd>GitBlameCopyPRURL<cr>", desc = "Copy blame PR URL" },
    { "<leader>gbf", "<cmd>GitBlameOpenFileURL<cr>", desc = "Open blame file URL" },
    { "<leader>gby", "<cmd>GitBlameCopyFileURL<cr>", desc = "Copy blame file URL" },
  },
  -- Because of the keys part, you will be lazy loading this plugin.
  -- The plugin will only load once one of the keys is used.
  -- If you want to load the plugin at startup, add something like event = "VeryLazy",
  -- or lazy = false. One of both options will work.
  opts = {
    -- your configuration comes here
    -- for example
    enabled = false, -- if you want to enable the plugin
    message_template = " <summary> • <date> • <author> • <<sha>>", -- template for the blame message, check the Message template section for more options
    date_format = "%d-%m-%Y %H:%M:%S", -- template for the date, check Date format section for more options
    virtual_text_column = 1, -- virtual text start column, check Start virtual text at column section for more options
  },
}
