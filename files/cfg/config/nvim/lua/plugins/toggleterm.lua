return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 17
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      auto_scroll = true,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "zig",
      callback = function()
        vim.keymap.set("n", "<cr>", function()
          local current_file = vim.fn.expand("%:t")

          local cmd = string.format("TermExec cmd='zig test %s' direction=vertical", current_file)

          vim.cmd(cmd)
        end, {
          buffer = true,
          desc = "Run Zig tests for current file",
        })
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "haskell",
      callback = function()
        vim.keymap.set("n", "<cr>", function()
          local cmd = string.format("TermExec cmd='clear; cabal run --verbose=0' direction=vertical")
          vim.cmd(cmd)
        end, {
          buffer = true,
          desc = "Run 'cabal run'",
        })
      end,
    })
  end,
}
