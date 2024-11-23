return {
  { "nvim-telescope/telescope.nvim", enabled = false },
  {
    "ibhagwan/fzf-lua",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      { "kevinhwang91/nvim-bqf", ft = "qf", opts = {} },
    },
    keys = {
      {
        "<leader>,",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Switch Buffer",
      },
      {
        "<leader>/",
        function()
          require("fzf-lua").grep_project()
        end,
        desc = "Grep (Root Dir)",
      },
      {
        "<leader>:",
        function()
          require("fzf-lua").command_history()
        end,
        desc = "Command History",
      },
      {
        "<leader>fb",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Buffers",
      },
      {
        "<c-n>",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fc",
        function()
          require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "Find Config File",
      },
      {
        "<leader>ff",
        function()
          require("fzf-lua").files()
        end,
        desc = "Find Files (Root Dir)",
      },
      {
        "<c-p>",
        function()
          require("fzf-lua").files()
        end,
        desc = "Find Files (Root Dir)",
      },
      {
        "<leader>fF",
        function()
          require("fzf-lua").files({ cwd = vim.fn.getcwd() })
        end,
        desc = "Find Files (cwd)",
      },
      {
        "<leader>fg",
        function()
          require("fzf-lua").git_files()
        end,
        desc = "Find Files (git-files)",
      },
      {
        "<leader>fr",
        function()
          require("fzf-lua").oldfiles()
        end,
        desc = "Recent",
      },
      {
        "<leader>fR",
        function()
          require("fzf-lua").oldfiles({ cwd = vim.fn.getcwd() })
        end,
        desc = "Recent (cwd)",
      },
      {
        "<leader>gc",
        function()
          require("fzf-lua").git_commits()
        end,
        desc = "Commits",
      },
      {
        "<leader>gs",
        function()
          require("fzf-lua").git_status()
        end,
        desc = "Status",
      },
      {
        '<leader>s"',
        function()
          require("fzf-lua").registers()
        end,
        desc = "Registers",
      },
      {
        "<leader>sa",
        function()
          require("fzf-lua").autocmds()
        end,
        desc = "Auto Commands",
      },
      {
        "<leader>sb",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Buffer",
      },
      {
        "<leader>sc",
        function()
          require("fzf-lua").command_history()
        end,
        desc = "Command History",
      },
      {
        "<leader>sC",
        function()
          require("fzf-lua").commands()
        end,
        desc = "Commands",
      },
      {
        "<leader>sd",
        function()
          require("fzf-lua").diagnostics_document()
        end,
        desc = "Document Diagnostics",
      },
      {
        "<leader>sD",
        function()
          require("fzf-lua").diagnostics_workspace()
        end,
        desc = "Workspace Diagnostics",
      },
      {
        "<leader>sg",
        function()
          require("fzf-lua").grep_project()
        end,
        desc = "Grep (Root Dir)",
      },
      {
        "<leader>sG",
        function()
          require("fzf-lua").grep_project({ cwd = vim.fn.getcwd() })
        end,
        desc = "Grep (cwd)",
      },
      {
        "<leader>sh",
        function()
          require("fzf-lua").help_tags()
        end,
        desc = "Help Pages",
      },
      {
        "<leader>sH",
        function()
          require("fzf-lua").highlights()
        end,
        desc = "Search Highlight Groups",
      },
      {
        "<leader>sj",
        function()
          require("fzf-lua").jumps()
        end,
        desc = "Jumplist",
      },
      {
        "<leader>sk",
        function()
          require("fzf-lua").keymaps()
        end,
        desc = "Key Maps",
      },
      {
        "<leader>sl",
        function()
          require("fzf-lua").loclist()
        end,
        desc = "Location List",
      },
      {
        "<leader>sm",
        function()
          require("fzf-lua").marks()
        end,
        desc = "Jump to Mark",
      },
      {
        "<leader>sM",
        function()
          require("fzf-lua").man_pages()
        end,
        desc = "Man Pages",
      },
      {
        "<leader>so",
        function()
          require("fzf-lua").vim_options()
        end,
        desc = "Options",
      },
      {
        "<leader>sq",
        function()
          require("fzf-lua").quickfix()
        end,
        desc = "Quickfix List",
      },
      {
        "<leader>sR",
        function()
          require("fzf-lua").resume()
        end,
        desc = "Resume",
      },
      {
        "<leader>ss",
        function()
          require("fzf-lua").lsp_document_symbols()
        end,
        desc = "Goto Symbol",
      },
      {
        "<leader>sS",
        function()
          require("fzf-lua").lsp_workspace_symbols()
        end,
        desc = "Goto Symbol (Workspace)",
      },
      {
        "<leader>sw",
        function()
          require("fzf-lua").grep_cword()
        end,
        desc = "Word (Root Dir)",
      },
      {
        "<leader>sW",
        function()
          require("fzf-lua").grep_cword({ cwd = vim.fn.getcwd() })
        end,
        desc = "Word (cwd)",
      },
      {
        "<leader>uC",
        function()
          require("fzf-lua").colorschemes()
        end,
        desc = "Colorscheme with Preview",
      },
      -- Visual mode mappings
      {
        "<leader>sw",
        function()
          require("fzf-lua").grep_visual()
        end,
        mode = "v",
        desc = "Selection (Root Dir)",
      },
      {
        "<leader>sW",
        function()
          require("fzf-lua").grep_visual({ cwd = vim.fn.getcwd() })
        end,
        mode = "v",
        desc = "Selection (cwd)",
      },
    },
    -- opts = {
    -- -- Global fzf-lua configuration options
    -- global_resume = true,
    -- global_history = true,
    -- winopts = {
    --   height = 0.85,
    --   width = 0.80,
    --   preview = {
    --     horizontal = "right:50%",
    --     layout = "horizontal",
    --   },
    -- },
    -- keymap = {
    --   fzf = {
    --     ["ctrl-c"] = "abort",
    --     ["ctrl-u"] = "unix-line-discard",
    --     ["ctrl-f"] = "half-page-down",
    --     ["ctrl-b"] = "half-page-up",
    --     ["ctrl-a"] = "beginning-of-line",
    --     ["ctrl-e"] = "end-of-line",
    --   },
    -- },
    -- },
    config = function()
      local actions = require("fzf-lua.actions")

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
          fd_opts = [[--color never --type f --hidden --follow --strip-cwd-prefix -E .git -E node_modules -E .venv -E .sqlx -E resource_snapshots ]],
          -- fd_opts = [[--color=never --type f --follow]],
        },
        grep = {
          rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
          actions = {
            ["ctrl-g"] = { actions.grep_lgrep },
            ["ctrl-r"] = { actions.toggle_ignore },
          },
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
          cmd = "fd -u --exclude .git --exclude .ipynb_checkpoints --exclude .sqlx --exclude node_modules --exclude resource_snapshots", -- default: auto detect fd|rg|find
        },
      })

      vim.keymap.set({ "i" }, "<C-x><C-f>", function()
        require("fzf-lua").complete_path()
      end, { silent = true, desc = "Fuzzy complete path" })
    end,
  },
}