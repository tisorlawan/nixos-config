return {
  'ibhagwan/fzf-lua',
  event = { 'BufReadPre', 'BufNewFile', 'VimEnter' },
  keys = {
    { '<C-n>', function() require('fzf-lua').buffers() end, desc = 'Buffers' },
    { '<leader>fF', function() require('fzf-lua').files { cwd = vim.fn.getcwd() } end, desc = 'Find files (cwd)' },
    { '<leader>fg', function() require('fzf-lua').git_files() end, desc = 'Find files (git)' },
    { '<leader>fr', function() require('fzf-lua').oldfiles() end, desc = 'Recent files' },
    { '<leader>fR', function() require('fzf-lua').oldfiles { cwd = vim.fn.getcwd() } end, desc = 'Recent files (cwd)' },
    { '<leader>gc', function() require('fzf-lua').git_commits() end, desc = 'Commits' },
    { '<leader>gs', function() require('fzf-lua').git_status() end, desc = 'Status' },
    { '<leader>fy', function() require('fzf-lua').registers() end, desc = 'Registers' },
    { '<leader>fx', function() require('fzf-lua').diagnostics_document() end, desc = 'Document diagnostics' },
    { '<leader>fX', function() require('fzf-lua').diagnostics_workspace() end, desc = 'Workspace diagnostics' },
    { '<leader>fm', function() require('fzf-lua').marks() end, desc = 'Marks' },
    { '<leader>fM', function() require('fzf-lua').man_pages() end, desc = 'Man pages' },
    { '<leader>f.', function() require('fzf-lua').resume() end, desc = 'Resume' },
    { '<leader>ss', function() require('fzf-lua').lsp_document_symbols() end, desc = 'Goto symbol' },
    { '<leader>S', function() require('fzf-lua').lsp_workspace_symbols() end, desc = 'Goto symbol (workspace)' },
    { '<leader>uC', function() require('fzf-lua').colorschemes() end, desc = 'Colorscheme picker' },
    { '<leader>cs', function() require('fzf-lua').lsp_document_symbols() end, desc = 'Document symbols' },
    { '<leader>cw', function() require('fzf-lua').lsp_live_workspace_symbols() end, desc = 'Workspace symbols' },
    { '<leader>ca', function() require('fzf-lua').lsp_code_actions() end, desc = 'Code actions' },
    {
      '<leader>fd',
      function()
        require('fzf-lua').fzf_exec(
          'fd -u --type d -E .cache -E snap -E cache -E go -E .git -E .npm -E .miniconda3 -E .conda -E __pycache__ -E .docker -E .cargo -E .cert -E .windsurf -E .minikube -E .ghcup -E .claude -E .stack -E .cabal -E .aws -E tmp -E .rustup -E uv -E .local/share -E .codeium -E .cargo_build_artifacts -E .ipython -E .ruff_cache -E .venv -E Slack -E node_modules -E .jupyter -E nltk_data -E .local/state -E .zoom',
          {
            prompt = '~/',
            cwd = '~',
            actions = {
              ['default'] = function(selected)
                if selected and #selected > 0 then
                  local root = vim.fn.expand '~' .. '/'
                  vim.cmd('cd ' .. root .. selected[1])
                  require('fzf-lua').files()
                end
              end,
            },
          }
        )
      end,
      desc = 'Fuzzy cd under home',
    },
  },
  config = function()
    local actions = require 'fzf-lua.actions'

    vim.cmd [[FzfLua register_ui_select]]

    require('fzf-lua').setup {
      winopts = { backdrop = 100, preview = { delay = 0 } },
      manpages = {
        previewer = 'man',
        actions = {
          ['default'] = function(selected)
            if not selected or not selected[1] then
              return
            end
            local manpage = require('fzf-lua.providers.manpages').manpage_vim_arg(selected[1])
            vim.cmd('vert Man ' .. manpage)
          end,
        },
      },
      helptags = { previewer = 'help_tags' },
      lsp = { code_actions = { previewer = 'codeaction' } },
      files = {
        fd_opts = '--color never --type f --hidden --follow --strip-cwd-prefix -E .git -E .jj -E node_modules -E .venv -E .sqlx -E resource_snapshots',
      },
      grep = {
        rg_opts = '--column --line-number --no-heading --color=never --smart-case --max-columns=4096 -e',
        winopts = { treesitter = { enabled = false } },
        actions = {
          ['ctrl-g'] = { actions.grep_lgrep },
          ['ctrl-r'] = { actions.toggle_ignore },
        },
      },
      defaults = { git_icons = true, file_icons = true },
      keymap = {
        fzf = {
          ['ctrl-q'] = 'select-all+accept',
          ['ctrl-y'] = 'toggle-preview',
          ['ctrl-x'] = 'abort',
        },
      },
      complete_path = {
        cmd = 'fd -u --exclude .git --exclude .ipynb_checkpoints --exclude .sqlx --exclude node_modules --exclude resource_snapshots',
      },
    }

    vim.keymap.set('i', '<C-x><C-f>', function()
      require('fzf-lua').complete_path()
    end, { desc = 'Fuzzy complete path', silent = true })
  end,
}
