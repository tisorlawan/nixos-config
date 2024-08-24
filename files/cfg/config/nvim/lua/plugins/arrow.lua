return {
  "otavioschwanck/arrow.nvim",
  opts = {
    show_icons = true,
    leader_key = ";", -- Recommended to be a single key
    buffer_leader_key = "m", -- Per Buffer Mappings
  },
  lazy = false,
  config = function(_, opts)
    require("arrow").setup(opts)
    -- vim.keymap.set("n", "H", require("arrow.persist").previous)
    -- vim.keymap.set("n", "L", require("arrow.persist").next)
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

-- return {
--   "ThePrimeagen/harpoon",
--   branch = "harpoon2",
--   config = function()
--     local harpoon = require("harpoon")
--     harpoon:setup({
--       settings = {
--         save_on_toggle = true,
--       },
--     })
--   end,
--   dependencies = {
--     "nvim-lua/plenary.nvim",
--     { "AstroNvim/astroui", opts = { icons = { Harpoon = "󱡀" } } },
--     {
--       "AstroNvim/astrocore",
--       opts = function(_, opts)
--         local maps = opts.mappings
--         local term_string = vim.fn.exists("$TMUX") == 1 and "tmux" or "term"
--         local prefix = "<Leader><Leader>"
--         maps.n[prefix] = { desc = require("astroui").get_icon("Harpoon", 1, true) .. "Harpoon" }
--
--         local harpoon = require("harpoon")
--
--         maps.n["<M-1>"] = {
--           function()
--             harpoon:list():select(1)
--           end,
--         }
--
--         maps.n["<M-2>"] = {
--           function()
--             harpoon:list():select(2)
--           end,
--         }
--
--         maps.n["<M-3>"] = {
--           function()
--             harpoon:list():select(3)
--           end,
--         }
--         maps.n["<M-4>"] = {
--           function()
--             harpoon:list():select(4)
--           end,
--         }
--
--         maps.n[prefix .. "a"] = {
--           function()
--             require("harpoon"):list():add()
--           end,
--           desc = "Add file",
--         }
--         maps.n[prefix .. "e"] = {
--           function()
--             require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
--           end,
--           desc = "Toggle quick menu",
--         }
--         maps.n["<C-x>"] = {
--           function()
--             vim.ui.input({ prompt = "Harpoon mark index: " }, function(input)
--               local num = tonumber(input)
--               if num then
--                 require("harpoon"):list():select(num)
--               end
--             end)
--           end,
--           desc = "Goto index of mark",
--         }
--         maps.n["<C-p>"] = {
--           function()
--             require("harpoon"):list():prev({ ui_nav_wrap = true })
--           end,
--           desc = "Goto previous mark",
--         }
--         maps.n["<C-n>"] = {
--           function()
--             require("harpoon"):list():next({ ui_nav_wrap = true })
--           end,
--           desc = "Goto next mark",
--         }
--         maps.n[prefix .. "m"] = { "<Cmd>Telescope harpoon marks<CR>", desc = "Show marks in Telescope" }
--         maps.n[prefix .. "t"] = {
--           function()
--             vim.ui.input({ prompt = term_string .. " window number: " }, function(input)
--               local num = tonumber(input)
--               if num then
--                 require("harpoon").term.gotoTerminal(num)
--               end
--             end)
--           end,
--           desc = "Go to " .. term_string .. " window",
--         }
--       end,
--     },
--   },
-- }
