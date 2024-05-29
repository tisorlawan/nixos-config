return {
  {
    "echasnovski/mini.indentscope",
    ft = { "python" },
    config = function()
      require("mini.indentscope").setup({
        draw = {
          delay = 0,
          animation = require("mini.indentscope").gen_animation.none(),
        },
        symbol = "│",
      })
    end,
  },
  {
    "echasnovski/mini.bufremove",
    version = "*",
    config = function()
      require("mini.bufremove").setup()

      vim.keymap.set("n", "<leader>c", MiniBufremove.delete, { desc = "delete buffer" })
      vim.keymap.set("n", "<leader>C", MiniBufremove.wipeout, { desc = "wipeout buffer" })
    end,
  },
}
