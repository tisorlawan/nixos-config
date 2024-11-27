return {
  "echasnovski/mini.nvim",
  version = false,
  specs = {
    { "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
  },
  init = function()
    package.preload["nvim-web-devicons"] = function()
      require("mini.icons").mock_nvim_web_devicons()
      return package.loaded["nvim-web-devicons"]
    end
  end,
  config = function()
    ----------------------
    require("mini.bufremove").setup()
    -- vim.keymap.set("n", "<leader>D", MiniBufremove.delete, { desc = "Wipeout buffer" })
    vim.keymap.set("n", "<leader>D", MiniBufremove.wipeout, { desc = "Buffer Wipeout" })

    ----------------------
    require("mini.indentscope").setup({
      draw = {
        delay = 0,
        animation = require("mini.indentscope").gen_animation.none(),
      },
      symbol = "│",
    })
    local f = function(args)
      local ft = vim.bo[args.buf].filetype
      if ft == "python" then
        return
      end
      vim.b[args.buf].miniindentscope_disable = true
    end
    vim.api.nvim_create_autocmd("Filetype", { callback = f })

    ----------------------
    require("mini.icons").setup({ style = "glyph" })
  end,
}
