return {
  "ggandor/leap.nvim",
  -- commit = "5ae080b646021bbb6e1d8715b155b1e633e28166",
  keys = {
    { "s", "<Plug>(leap-forward)", mode = { "n", "x", "o" }, desc = "leap forward to" },
    { "S", "<Plug>(leap-backward)", mode = { "n", "x", "o" }, desc = "leap backward to" },
    { "x", "<Plug>(leap-forward-till)", mode = { "x", "o" }, desc = "leap forward till" },
    { "X", "<Plug>(leap-backward-till)", mode = { "x", "o" }, desc = "leap backward till" },
    { "gs", "<Plug>(leap-from-window)", mode = { "n", "x", "o" }, desc = "leap from window" },
  },
  opts = {
    safe_labels = "tyuofghjklvbn",
    labels = "sfnjklhowembuyvrgtqpcxz/SFNJKLHOWEIMBUYVRGTAQPCXZ",
  },
  init = function()
    -- https://github.com/ggandor/leap.nvim/issues/70#issuecomment-1521177534
    -- vim.api.nvim_create_autocmd("User", {
    --   callback = function()
    --     vim.cmd.hi("Cursor", "blend=100")
    --     vim.opt.guicursor:append({ "a:Cursor/lCursor" })
    --   end,
    --   pattern = "LeapEnter",
    -- })
    --
    -- vim.api.nvim_create_autocmd("User", {
    --   callback = function()
    --     vim.cmd.hi("Cursor", "blend=0")
    --     vim.opt.guicursor:remove({ "a:Cursor/lCursor" })
    --   end,
    --   pattern = "LeapLeave",
    -- })

    -- vim.keymap.set({ "n", "o" }, "gw", function()
    --   require("leap.remote").action()
    -- end)
  end,
  dependencies = {
    "tpope/vim-repeat",
  },
}
