vim.pack.add {
  'https://github.com/nvim-orgmode/orgmode',
  'https://github.com/nvim-orgmode/org-bullets.nvim',
}

require('orgmode').setup {
  org_agenda_files = '~/notes/**/*',
  org_default_notes_file = '~/notes/refile.org',
  org_todo_keywords = { 'TODO', 'IN_PROGRESS', 'WAITING', '|', 'DONE', 'DELEGATED' },
  org_hide_leading_stars = true,
}

-- Experimental LSP support
vim.lsp.enable 'org'

require('org-bullets').setup()
