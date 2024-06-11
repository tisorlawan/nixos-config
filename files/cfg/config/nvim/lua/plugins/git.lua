return {
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]h", function()
            if vim.wo.diff then
              return "]h"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "next hunk" })

          map("n", "[h", function()
            if vim.wo.diff then
              return "[h"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "prev hunk" })

          -- Actions
          map("n", "<Leader>hs", gs.stage_hunk, { desc = "stage hunk" })
          map("n", "<Leader>hr", gs.reset_hunk, { desc = "reset hunk" })
          map("v", "<Leader>hs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "stage hunk" })
          map("v", "<Leader>hr", function()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "reset hunk" })
          map("n", "<Leader>hS", gs.stage_buffer, { desc = "stage buffer" })
          map("n", "<Leader>hu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
          map("n", "<Leader>hR", gs.reset_buffer, { desc = "reset buffer" })
          map("n", "<Leader>hp", gs.preview_hunk, { desc = "preview hunk" })
          map("n", "<Leader>hb", function()
            gs.blame_line({ full = true }, { desc = "blame line" })
          end, { desc = "blame line" })
          map("n", "<Leader>tb", gs.toggle_current_line_blame, { desc = "toggle blame line" })
          map("n", "<Leader>hd", gs.diffthis, { desc = "diff this" })
          map("n", "<Leader>hD", function()
            gs.diffthis("~")
          end, { desc = "diff this ~" })
          map("n", "<Leader>hd", gs.toggle_deleted, { desc = "toggle deleted" })

          -- Text object
          map({ "o", "x" }, "ig", ":<C-U>Gitsigns select_hunk<CR>")
        end,
      })
    end,
  },
}
