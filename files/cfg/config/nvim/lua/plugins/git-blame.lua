return {
  'f-person/git-blame.nvim',
  keys = {
    { '<leader>gbo', '<cmd>GitBlameOpenCommitURL<cr>', desc = 'Open blame commit URL' },
    { '<leader>gbb', '<cmd>GitBlameToggle<cr>', desc = 'Toggle git blame' },
    { '<leader>gbe', '<cmd>GitBlameEnable<cr>', desc = 'Enable git blame' },
    { '<leader>gbd', '<cmd>GitBlameDisable<cr>', desc = 'Disable git blame' },
    { '<leader>gbs', '<cmd>GitBlameCopySHA<cr>', desc = 'Copy blame SHA' },
    { '<leader>gbc', '<cmd>GitBlameCopyCommitURL<cr>', desc = 'Copy blame commit URL' },
    { '<leader>gbp', '<cmd>GitBlameCopyPRURL<cr>', desc = 'Copy blame PR URL' },
    { '<leader>gbf', '<cmd>GitBlameOpenFileURL<cr>', desc = 'Open blame file URL' },
    { '<leader>gby', '<cmd>GitBlameCopyFileURL<cr>', desc = 'Copy blame file URL' },
  },
  opts = {
    enabled = false,
    message_template = ' <summary> • <date> • <author> • <<sha>>',
    date_format = '%d-%m-%Y %H:%M:%S',
    virtual_text_column = 1,
  },
}
