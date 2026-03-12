return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc, silent = true })
      end

      map('n', ']h', function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gs.nav_hunk 'next'
        end
      end, 'Next hunk')
      map('n', '[h', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gs.nav_hunk 'prev'
        end
      end, 'Prev hunk')
      map('n', ']H', function() gs.nav_hunk 'last' end, 'Last hunk')
      map('n', '[H', function() gs.nav_hunk 'first' end, 'First hunk')
      map({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', 'Stage hunk')
      map({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', 'Reset hunk')
      map('n', '<leader>hS', gs.stage_buffer, 'Stage buffer')
      map('n', '<leader>hu', gs.undo_stage_hunk, 'Undo stage hunk')
      map('n', '<leader>hR', gs.reset_buffer, 'Reset buffer')
      map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
      map('n', '<C-q>', gs.preview_hunk_inline, 'Preview hunk inline')
      map('n', '<leader>hb', function() gs.blame_line { full = true } end, 'Blame line')
      map('n', '<leader>hB', gs.blame, 'Blame buffer')
      map('n', '<leader>hd', gs.diffthis, 'Diff this')
      map('n', '<leader>hD', function() gs.diffthis '~' end, 'Diff this ~')
      map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'Select hunk')
    end,
  },
}
