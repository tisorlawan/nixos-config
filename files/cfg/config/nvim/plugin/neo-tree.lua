vim.pack.add { 'https://github.com/nvim-neo-tree/neo-tree.nvim' }

vim.keymap.set('n', '<leader>e', ':Neotree source=filesystem reveal=true position=right toggle<Cr>', { desc = 'Toggle NeoTree', silent = true })

local function copy_path(state)
  local node = state.tree:get_node()
  local filepath = node:get_id()
  local filename = node.name
  local modify = vim.fn.fnamemodify
  local results = {
    filepath,
    modify(filepath, ':.'),
    modify(filepath, ':~'),
    filename,
    modify(filename, ':r'),
    modify(filename, ':e'),
  }
  local options = {
    { label = 'Absolute path', value = results[1] },
    { label = 'Path relative to CWD', value = results[2] },
    { label = 'Path relative to HOME', value = results[3] },
    { label = 'Filename', value = results[4] },
    { label = 'Filename without extension', value = results[5] },
    { label = 'Extension', value = results[6] },
  }

  vim.ui.select(options, {
    prompt = 'Choose to copy to clipboard:',
    format_item = function(item)
      return string.format('%s: %s', item.label, item.value)
    end,
  }, function(choice)
    if choice then
      vim.fn.setreg('+', choice.value)
      vim.notify('Copied: ' .. choice.value)
    end
  end)
end

local function refresh_filesystem(state)
  require('neo-tree.sources.filesystem')._navigate_internal(state, nil, nil, nil, false)
end

local function toggle_gitignored(state)
  state.filtered_items.hide_gitignored = not state.filtered_items.hide_gitignored
  vim.notify('Toggling gitignored files: ' .. tostring(not state.filtered_items.hide_gitignored), vim.log.levels.INFO, { title = 'Neo-tree' })
  refresh_filesystem(state)
end

local function open_with_relative_path(state)
  local node = state.tree:get_node()
  if node.type == 'directory' then
    require('neo-tree.sources.filesystem.commands').toggle_node(state)
    return
  end
  if node.type ~= 'file' then
    return
  end

  local abs_path = node:get_id()
  local target_buf = vim.fn.bufnr(abs_path)
  if target_buf ~= -1 then
    local win = vim.fn.bufwinid(target_buf)
    if win ~= -1 then
      vim.api.nvim_set_current_win(win)
      return
    end
  end

  local path = abs_path
  local relative = vim.fn.fnamemodify(abs_path, ':.')
  if not relative:match '^%.%.' then
    path = relative
  end

  local real_wins = vim.tbl_filter(function(win)
    local buf = vim.api.nvim_win_get_buf(win)
    local buftype = vim.bo[buf].buftype
    local filetype = vim.bo[buf].filetype
    return buftype ~= 'nofile' and buftype ~= 'prompt' and filetype ~= 'neo-tree'
  end, vim.api.nvim_list_wins())

  if #real_wins == 0 then
    vim.cmd.vsplit()
  else
    vim.api.nvim_set_current_win(real_wins[1])
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(path))
end

require('neo-tree').setup {
  close_if_last_window = true,
  enable_git_status = true,
  window = {
    mappings = {
      I = toggle_gitignored,
      Y = copy_path,
      ['<cr>'] = open_with_relative_path,
      o = open_with_relative_path,
      ['<2-LeftMouse>'] = open_with_relative_path,
    },
  },
  filesystem = {
    follow_current_file = { enabled = false },
    use_libuv_file_watcher = true,
    hijack_netrw_behavior = 'disabled',
    filtered_items = { always_show = { '.gitignore' } },
  },
}
