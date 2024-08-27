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
        -- fzf_opts = { ["--ansi"] = false },
        fd_opts = [[--color never --type f --hidden --follow --strip-cwd-prefix -E .git -E node_modules -E .sqlx]],
        -- fd_opts = [[--color=never --type f --follow]],
      },
      defaults = {
        git_icons = true,
        file_icons = true,
      },
      keymap = {
        fzf = {
          ["ctrl-q"] = "select-all+accept",
          ["ctrl-y"] = "toggle-preview",
          ["ctrl-x"] = "abort",
        },
      },
      complete_path = {
        cmd = "fd -u --exclude .git --exclude .ipynb_checkpoints --exclude .sqlx --exclude node_modules", -- default: auto detect fd|rg|find
      },
    })

    vim.keymap.set({ "n", "v", "i" }, "<C-x><C-f>", function()
      require("fzf-lua").complete_path()
    end, { silent = true, desc = "Fuzzy complete path" })

    map("<leader>s", "<cmd>lua require('fzf-lua').grep()<cr>", "grep")

    map("<leader>fn", "<cmd>lua require('fzf-lua').builtin()<cr>", "builtins")
    map("<leader>fk", "<cmd>lua require('fzf-lua').keymaps()<cr>", "keymaps")

    map("<leader>fr", "<cmd>lua require('fzf-lua').resume()<cr>", "resume files")
    -- map("<leader>ff", "<cmd>lua require('fzf-lua').files({winopts = {preview = {hidden = 'hidden'}}})<cr>", "files")
    map("<c-n>", "<cmd>lua require('fzf-lua').files({winopts = {preview = {hidden = 'hidden'}}})<cr>", "files")

    map(
      "<leader>fa",
      [[<cmd>lua require('fzf-lua').files({ cmd = "fd --color=never --type f --hidden --follow -E .git -E node_modules -E .sqlx", winopts = {preview = {hidden = 'hidden'}} })<cr>]],
      "all files"
    )
    map("<leader>fg", "<cmd>lua require('fzf-lua').git_files()<cr>", "git files")
    map("<leader>fl", "<cmd>lua require('fzf-lua').lines()<cr>", "lines")

    map("<leader>fj", "<cmd>lua require('fzf-lua').jumps()<cr>", "Jumps")

    map("<leader>fw", "<cmd>lua require('fzf-lua').live_grep()<cr>", "live grep")
    map("<leader>fW", "<cmd>lua require('fzf-lua').live_grep_resume()<cr>", "live grep resume")

    -- map("<leader>fb", "<cmd>lua require('fzf-lua').buffers()<cr>", "buffers")
    map("<c-p>", "<cmd>lua require('fzf-lua').buffers()<cr>", "buffers")
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

    vim.keymap.set("v", "gs", "<cmd>lua require('fzf-lua').grep_visual()<cr>", { desc = "grep visual" })
  end,
}
