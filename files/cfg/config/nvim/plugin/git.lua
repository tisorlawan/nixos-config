vim.pack.add {
  'https://github.com/f-person/git-blame.nvim',
  'https://github.com/wintermute-cell/gitignore.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
}

local map = vim.keymap.set

map('n', '<leader>gbo', '<cmd>GitBlameOpenCommitURL<cr>', { desc = 'Open blame commit URL' })
map('n', '<leader>gbb', '<cmd>GitBlameToggle<cr>', { desc = 'Toggle git blame' })
map('n', '<leader>gbe', '<cmd>GitBlameEnable<cr>', { desc = 'Enable git blame' })
map('n', '<leader>gbd', '<cmd>GitBlameDisable<cr>', { desc = 'Disable git blame' })
map('n', '<leader>gbs', '<cmd>GitBlameCopySHA<cr>', { desc = 'Copy blame SHA' })
map('n', '<leader>gbc', '<cmd>GitBlameCopyCommitURL<cr>', { desc = 'Copy blame commit URL' })
map('n', '<leader>gbp', '<cmd>GitBlameCopyPRURL<cr>', { desc = 'Copy blame PR URL' })
map('n', '<leader>gbf', '<cmd>GitBlameOpenFileURL<cr>', { desc = 'Open blame file URL' })
map('n', '<leader>gby', '<cmd>GitBlameCopyFileURL<cr>', { desc = 'Copy blame file URL' })

require('gitblame').setup {
  enabled = false,
  message_template = ' <summary> • <date> • <author> • <<sha>>',
  date_format = '%d-%m-%Y %H:%M:%S',
  virtual_text_column = 1,
}

vim.api.nvim_create_user_command('Eorig', function(opts)
  local file = opts.args
  if file == '' then
    file = vim.fn.expand '%'
  end

  local abs = vim.fn.fnamemodify(file, ':p')
  local dir = vim.fn.fnamemodify(abs, ':h')
  local out = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(dir) .. ' rev-parse --show-toplevel')
  if vim.v.shell_error ~= 0 then
    vim.notify('Eorig: not in a git repo', vim.log.levels.ERROR)
    return
  end
  local git_root = out[1]

  local rel = abs:gsub('^' .. vim.pesc(git_root .. '/'), '')
  local lines = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(git_root) .. ' show HEAD:' .. vim.fn.shellescape(rel))
  if vim.v.shell_error ~= 0 then
    vim.notify('Eorig: not tracked in HEAD: ' .. rel, vim.log.levels.ERROR)
    return
  end

  local ft = vim.bo.filetype
  vim.cmd.vsplit()
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_name(buf, rel .. ' (HEAD)')
  vim.bo[buf].buftype = 'nowrite'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = ft
  vim.api.nvim_set_current_buf(buf)
end, { nargs = '?', complete = 'file', desc = 'View file from git HEAD in split' })

require('gitsigns').setup {
  signcolumn = false,
  preview_config = {
    -- single double solid shadow
    border = 'single',
  },
  on_attach = function(buffer)
    local gs = package.loaded.gitsigns
    local function lmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc, silent = true })
    end

    lmap('n', ']h', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gs.nav_hunk 'next'
      end
    end, 'Next hunk')
    lmap('n', '[h', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gs.nav_hunk 'prev'
      end
    end, 'Prev hunk')
    lmap('n', ']H', function()
      gs.nav_hunk 'last'
    end, 'Last hunk')
    lmap('n', '[H', function()
      gs.nav_hunk 'first'
    end, 'First hunk')
    lmap({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', 'Stage hunk')
    lmap({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', 'Reset hunk')
    lmap('n', '<leader>hS', gs.stage_buffer, 'Stage buffer')
    lmap('n', '<leader>hu', gs.undo_stage_hunk, 'Undo stage hunk')
    lmap('n', '<leader>hR', gs.reset_buffer, 'Reset buffer')
    lmap('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
    lmap('n', '<C-q>', gs.preview_hunk_inline, 'Preview hunk inline')
    lmap('n', '<leader>hb', function()
      gs.blame_line { full = true }
    end, 'Blame line')
    lmap('n', '<leader>hB', gs.blame, 'Blame buffer')
    lmap('n', '<leader>hd', gs.diffthis, 'Diff this')
    lmap('n', '<leader>hD', function()
      gs.diffthis '~'
    end, 'Diff this ~')
    lmap({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Select hunk')
    lmap('n', '<leader>ug', ':Gitsigns toggle_signs<cr>', 'Toggle git signs')
  end,
}
