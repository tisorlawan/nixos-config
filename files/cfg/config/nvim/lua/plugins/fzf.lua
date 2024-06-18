local function map(key, cmd, desc)
  vim.keymap.set("n", key, cmd, { silent = true, noremap = true, desc = desc })
end

return {
  "ibhagwan/fzf-lua",
  lazy = false,
  dependencies = {
    { "kevinhwang91/nvim-bqf", ft = "qf", opts = {} },
  },
  config = function()
    require("fzf-lua").setup({
      winopts = {
        preview = {
          default = "bat",
          delay = 0,
        },
      },
      manpages = { previewer = "man_native" },
      helptags = { previewer = "help_native" },
      lsp = { code_actions = { previewer = "codeaction_native" } },
      tags = { previewer = "bat" },
      btags = { previewer = "bat" },
      files = {
        fzf_opts = { ["--ansi"] = false },
        fd_opts = [[--color=never --type f --follow]],
      },
      defaults = {
        git_icons = false,
        file_icons = false,
      },
      keymap = {
        fzf = {
          ["ctrl-q"] = "select-all+accept",
          ["ctrl-y"] = "toggle-preview",
          ["ctrl-x"] = "abort",
        },
      },
      complete_path = {
        cmd = "fd -u --exclude .git --exclude .ipynb_checkpoints --exclude node_modules", -- default: auto detect fd|rg|find
      },
    })

    vim.keymap.set({ "n", "v", "i" }, "<C-x><C-f>", function()
      require("fzf-lua").complete_path()
    end, { silent = true, desc = "Fuzzy complete path" })

    map("<leader>fn", "<cmd>lua require('fzf-lua').builtin()<cr>", "builtins")
    map("<leader>fk", "<cmd>lua require('fzf-lua').keymaps()<cr>", "keymaps")

    map("<leader>fr", "<cmd>lua require('fzf-lua').resume()<cr>", "resume files")
    map("<leader>ff", "<cmd>lua require('fzf-lua').files({winopts = {preview = {hidden = 'hidden'}}})<cr>", "files")

    map(
      "<leader>fa",
      [[<cmd>lua require('fzf-lua').files({ cmd = "fd --color=never --type f --hidden --follow -E .git -E node_modules", winopts = {preview = {hidden = 'hidden'}} })<cr>]],
      "all files"
    )
    map("<leader>fg", "<cmd>lua require('fzf-lua').git_files()<cr>", "git files")
    map("<leader>fl", "<cmd>lua require('fzf-lua').lines()<cr>", "lines")

    map("<leader>fw", "<cmd>lua require('fzf-lua').live_grep()<cr>", "live grep")
    map("<leader>fW", "<cmd>lua require('fzf-lua').live_grep_resume()<cr>", "live grep resume")

    map("<leader>fb", "<cmd>lua require('fzf-lua').buffers()<cr>", "buffers")
    map("<leader>f.", "<cmd>lua require('fzf-lua').grep_cWORD()<cr>", "grep cWORD")
    map("<leader>fm", "<cmd>lua require('fzf-lua').marks()<cr>", "marks")
    map('<leader>f"', "<cmd>lua require('fzf-lua').registers()<cr>", "registers")
    map("<leader>fh", "<cmd>lua require('fzf-lua').help_tags()<cr>", "help")
    map("<leader>fq", "<cmd>lua require('fzf-lua').quickfix()<cr>", "quick fix")

    map("<leader>f/", "<cmd>lua require('fzf-lua').search_history()<cr>", "search history")
    map("<leader>f:", "<cmd>lua require('fzf-lua').command_history()<cr>", "command history")

    map("gR", "<cmd>lua require('fzf-lua').lsp_references()<cr>", "lsp references")
    map("gD", "<cmd>lua require('fzf-lua').lsp_definitions()<cr>", "lsp definitions")

    map("<leader>ll", "<cmd>lua require('fzf-lua').lsp_finder()<cr>", "lsp finder")
    map("<leader>lr", "<cmd>lua require('fzf-lua').lsp_references()<cr>", "lsp references")
    map("<leader>ls", "<cmd>lua require('fzf-lua').lsp_document_symbols()<cr>", "lsp document symbols")
    map("<leader>lS", "<cmd>lua require('fzf-lua').lsp_workspace_symbols()<cr>", "lsp workspace symbols")
    map("<leader>li", "<cmd>lua require('fzf-lua').lsp_incoming_calls()<cr>", "lsp incoming symbols")
    map("<leader>lo", "<cmd>lua require('fzf-lua').lsp_outgoing_calls()<cr>", "lsp outgoing symbols")

    map("<leader>gf", "<cmd>lua require('fzf-lua').git_files()<cr>", "git files")
    map("<leader>gs", "<cmd>lua require('fzf-lua').git_status()<cr>", "git status")
    map("<leader>gb", "<cmd>lua require('fzf-lua').git_branches()<cr>", "git branches")
    map("<leader>gt", "<cmd>lua require('fzf-lua').git_tags()<cr>", "git tags")
    map("<leader>gc", "<cmd>lua require('fzf-lua').git_commits()<cr>", "git commits")

    -- -- Fuzzy find all the symbols in your current document.
    -- --  Symbols are things like variables, functions, types, etc.
    -- -- map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

    -- -- Fuzzy find all the symbols in your current workspace.
    -- --  Similar to document symbols, except searches over your entire project.
    -- -- map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- map("<leader>fd", [[<CMD>lua require('fzf-lua').lsp_document_diagnostics()<CR>]], silent_noremap)
    -- map("<leader>fn", [[<CMD>lua require('fzf-lua').lsp_workspace_diagnostics()<CR>]], silent_noremap)
    --
    --
    -- map("<leader>fa", "<cmd>lua require('fzf-lua').lsp_code_actions()<cr>", "code actions")
    -- require('fzf-lua').setup {
    --   winopts = {
    --     hl = {
    --       border = 'FloatBorder',
    --     },
    --   },
    --   preview_layout = 'flex',
    --   flip_columns = 150,
    --   keymap = {
    --     fzf = {
    --       ['ctrl-q'] = 'select-all+accept',
    --     },
    --   },
    --   fzf_opts = {
    --     ['--border'] = 'none',
    --   },
    --   previewers = {
    --     builtin = {
    --       scrollbar = false,
    --     },
    --   },
    --   buffers = {
    --     git_icons = false,
    --     actions = {
    --       ['ctrl-w'] = actions.buf_del,
    --     },
    --   },
    --   files = {
    --     fd_opts = [[--color never --type f --hidden --follow --strip-cwd-prefix -E .git -E node_modules]],
    --     git_icons = false,
    --   },
    --   lsp = {
    --     async_or_timeout = false,
    --     severity = 'Warning',
    --     -- icons = {
    --     --   ['Error'] = { icon = vim.g.diagnostic_icons.Error, color = 'red' },
    --     --   ['Warning'] = { icon = vim.g.diagnostic_icons.Warning, color = 'yellow' },
    --     --   ['Information'] = { icon = vim.g.diagnostic_icons.Information, color = 'blue' },
    --     --   ['Hint'] = { icon = vim.g.diagnostic_icons.Hint, color = 'blue' },
    --     -- },
    --     actions = {
    --       ['default'] = actions.file_edit_or_qf,
    --     },
    --   },
    -- }
  end,
}
