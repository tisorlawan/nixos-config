return {
  "otavioschwanck/arrow.nvim",
  opts = {
    show_icons = true,
    leader_key = ";",
    buffer_leader_key = "m",
  },
  lazy = false,
  config = function(_, opts)
    require("arrow").setup(opts)
    vim.keymap.set("n", "H", require("arrow.persist").previous)
    vim.keymap.set("n", "L", require("arrow.persist").next)
    vim.keymap.set("n", "<M-1>", function()
      require("arrow.persist").go_to(1)
    end)
    vim.keymap.set("n", "<M-2>", function()
      require("arrow.persist").go_to(2)
    end)
    vim.keymap.set("n", "<M-3>", function()
      require("arrow.persist").go_to(3)
    end)
    vim.keymap.set("n", "<M-4>", function()
      require("arrow.persist").go_to(4)
    end)
  end,
}
