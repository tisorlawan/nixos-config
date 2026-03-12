local M = {}

local harpoon_files = {}
local harpoon_dir = vim.fn.expand '~/.vim/harpoon'
local fzf_source_win = 0
local fzf_tempfile = vim.fn.tempname()
local fuzzy_finder_cache

local function get_storage_file()
  local cwd = vim.fn.getcwd()
  local hash = vim.fn.sha256(cwd):sub(1, 16)

  if vim.fn.isdirectory(harpoon_dir) == 0 then
    vim.fn.mkdir(harpoon_dir, 'p', tonumber('755', 8))
  end

  return harpoon_dir .. '/' .. hash
end

local function load_files()
  local file = get_storage_file()
  if vim.fn.filereadable(file) == 1 then
    harpoon_files = vim.fn.readfile(file)
  else
    harpoon_files = {}
  end
end

local function save_files()
  vim.fn.writefile(harpoon_files, get_storage_file())
end

local function save_from_buffer(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  harpoon_files = vim.tbl_filter(function(line)
    return line ~= ''
  end, lines)
  save_files()
end

local function get_fuzzy_finder()
  if fuzzy_finder_cache ~= nil then
    return fuzzy_finder_cache
  end

  if vim.fn.executable 'fzf' == 1 then
    fuzzy_finder_cache = 'fzf'
  elseif vim.fn.executable 'fzy' == 1 then
    fuzzy_finder_cache = 'fzy'
  else
    fuzzy_finder_cache = ''
  end

  return fuzzy_finder_cache
end

local function open_picker_terminal(cmd, name, on_done, height)
  local resolved_height = height or 15
  local width = math.floor(vim.o.columns * 0.6)
  local float_height = math.floor(vim.o.lines * 0.4)
  local row = math.floor((vim.o.lines - float_height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  local use_float = vim.fn.has 'nvim-0.9' == 1
  local term_buf = vim.api.nvim_create_buf(false, true)
  local term_win

  if use_float then
    term_win = vim.api.nvim_open_win(term_buf, true, {
      relative = 'editor',
      width = width,
      height = float_height,
      row = row,
      col = col,
      style = 'minimal',
      border = 'rounded',
      title = ' ' .. name .. ' ',
      title_pos = 'center',
    })
  else
    vim.cmd('botright ' .. resolved_height .. 'new')
    term_buf = vim.api.nvim_get_current_buf()
    term_win = vim.api.nvim_get_current_win()
    vim.wo[term_win].statusline = '%#StatusLine# ' .. name .. ' %='
  end

  vim.bo[term_buf].bufhidden = 'wipe'
  vim.fn.jobstart({ 'sh', '-c', cmd }, {
    term = true,
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(term_buf) then
          vim.api.nvim_buf_delete(term_buf, { force = true })
        end
        if on_done then
          on_done()
        end
      end)
    end,
  })

  vim.cmd.startinsert()
end

local function open_selection(lines)
  if #lines == 0 or lines[1] == '' or vim.fn.filereadable(lines[1]) ~= 1 then
    return
  end

  if vim.fn.win_gotoid(fzf_source_win) == 1 then
    vim.cmd('edit ' .. vim.fn.fnameescape(lines[1]))
  end
end

local function add_file()
  load_files()
  local file = vim.fn.expand '%:.'
  if file == '' then
    print 'No file'
    return
  end

  for index, existing in ipairs(harpoon_files) do
    if existing == file then
      print('Already harpooned (' .. index .. ')')
      return
    end
  end

  table.insert(harpoon_files, file)
  save_files()
  print('Harpooned (' .. #harpoon_files .. '): ' .. file)
end

local function remove_file()
  load_files()
  local file = vim.fn.expand '%:.'
  if file == '' then
    print 'No file'
    return
  end

  for index, existing in ipairs(harpoon_files) do
    if existing == file then
      table.remove(harpoon_files, index)
      save_files()
      print('Removed: ' .. file)
      return
    end
  end

  print 'Not harpooned'
end

local function edit_list()
  load_files()

  local width = math.floor(vim.o.columns * 0.5)
  local height = math.max(math.min(#harpoon_files + 2, math.floor(vim.o.lines * 0.4)), 5)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, harpoon_files)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Harpoon ',
    title_pos = 'center',
  })

  vim.bo[buf].buftype = 'acwrite'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_name(buf, '[Harpoon]')

  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = buf,
    callback = function()
      save_from_buffer(buf)
      vim.bo[buf].modified = false
      print 'Harpoon saved'
    end,
  })

  local function close_and_save()
    save_from_buffer(buf)
    vim.api.nvim_win_close(win, true)
    print 'Harpoon saved'
  end

  vim.keymap.set('n', 'q', close_and_save, { buffer = buf })
  vim.keymap.set('n', '<Esc>', close_and_save, { buffer = buf })
end

local function go_to(index)
  load_files()
  if index <= 0 or index > #harpoon_files then
    print('No harpoon at ' .. index)
    return
  end

  local file = harpoon_files[index]
  if vim.fn.filereadable(file) == 1 then
    vim.cmd('edit ' .. vim.fn.fnameescape(file))
  else
    print('File not found: ' .. file)
  end
end

local function show_menu()
  load_files()
  if #harpoon_files == 0 then
    print 'No harpooned files'
    return
  end

  fzf_source_win = vim.api.nvim_get_current_win()
  local finder = get_fuzzy_finder()

  if finder == '' then
    for index, file in ipairs(harpoon_files) do
      print(index .. ': ' .. file)
    end
    return
  end

  fzf_tempfile = vim.fn.tempname()
  local list = table.concat(harpoon_files, '\n')
  local cmd = 'echo ' .. vim.fn.shellescape(list) .. ' | ' .. finder .. ' > ' .. fzf_tempfile

  open_picker_terminal(cmd, '[Harpoon]', function()
    if vim.fn.filereadable(fzf_tempfile) == 1 then
      local lines = vim.fn.readfile(fzf_tempfile)
      vim.fn.delete(fzf_tempfile)
      open_selection(lines)
    end
  end)
end

function M.setup()
  local map = vim.keymap.set

  map('n', '<leader>oa', add_file, { desc = 'Harpoon add' })
  map('n', '<leader>or', remove_file, { desc = 'Harpoon remove' })
  map('n', '<leader>oe', edit_list, { desc = 'Harpoon edit' })
  map('n', '<leader>om', show_menu, { desc = 'Harpoon menu' })
  map('n', '<M-1>', function()
    go_to(1)
  end, { desc = 'Harpoon 1' })
  map('n', '<M-2>', function()
    go_to(2)
  end, { desc = 'Harpoon 2' })
  map('n', '<M-3>', function()
    go_to(3)
  end, { desc = 'Harpoon 3' })
  map('n', '<M-4>', function()
    go_to(4)
  end, { desc = 'Harpoon 4' })
  map('n', '<M-5>', function()
    go_to(5)
  end, { desc = 'Harpoon 5' })
end

return M
