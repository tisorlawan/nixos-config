return {
  {
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
      vim.keymap.set("n", "<leader>c", MiniBufremove.delete, { desc = "delete buffer" })
      vim.keymap.set("n", "<leader>C", MiniBufremove.wipeout, { desc = "wipeout buffer" })

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

      ----------------------
      require("mini.comment").setup()

      ----------------------
      require("mini.files").setup({
        windows = {
          preview = true,
          width_preview = 60,
        },
      })
      vim.keymap.set("n", "-", "<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0), true)<cr>", { silent = true })
      vim.keymap.set("n", "<M-->", "<cmd>lua MiniFiles.open(nil, false)<cr>", { silent = true })

      ----------------------
      require("mini.trailspace").setup()
      ----------------------
    end,
  },
}
