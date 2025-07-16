local set = vim.opt_local

set.expandtab = true
set.tabstop = 2
set.shiftwidth = 2

-- Function to determine split direction based on window size
local function get_split_command()
  local width = vim.api.nvim_win_get_width(0)
  local height = vim.api.nvim_win_get_height(0)

  -- If window is wider than it is tall, split horizontally
  -- If window is taller than it is wide, split vertically
  if width > height * 1.5 then
    return "vnew" -- vertical split
  else
    return "new" -- horizontal split
  end
end

-- Store reference to scratch buffer for reuse
local scratch_buffer = nil
local scratch_window = nil

-- Function to execute shell script and show output in scratch buffer
local function run_shell_script()
  local current_file = vim.fn.expand("%:p")

  if current_file == "" then
    print("No file to execute")
    return
  end

  -- Check if file is executable, if not make it executable
  local file_stat = vim.loop.fs_stat(current_file)
  if file_stat and not vim.fn.executable(current_file) then
    vim.fn.system("chmod +x " .. vim.fn.shellescape(current_file))
  end

  -- Get the command to run
  local cmd = vim.fn.shellescape(current_file)

  -- Execute the script and capture output
  local output = vim.fn.systemlist(cmd)
  local exit_code = vim.v.shell_error

  -- Store current window to return to it later
  local original_window = vim.api.nvim_get_current_win()

  -- Check if scratch buffer and window still exist
  local reuse_buffer = false
  if scratch_buffer and vim.api.nvim_buf_is_valid(scratch_buffer) then
    if scratch_window and vim.api.nvim_win_is_valid(scratch_window) then
      -- Buffer and window exist, no need to switch cursor
      reuse_buffer = true
    else
      -- Buffer exists but window doesn't, need to split again
      local split_cmd = get_split_command()
      vim.cmd("noswapfile " .. split_cmd)
      vim.api.nvim_win_set_buf(0, scratch_buffer)
      scratch_window = vim.api.nvim_get_current_win()
      reuse_buffer = true
      -- Return to original window
      vim.api.nvim_set_current_win(original_window)
    end
  end

  -- Create new buffer if needed
  if not reuse_buffer then
    local split_cmd = get_split_command()
    vim.cmd("noswapfile " .. split_cmd)
    scratch_buffer = vim.api.nvim_get_current_buf()
    scratch_window = vim.api.nvim_get_current_win()
    vim.api.nvim_buf_set_option(scratch_buffer, "buftype", "nofile")
    vim.api.nvim_buf_set_option(scratch_buffer, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(scratch_buffer, "filetype", "text")
    -- Return to original window
    vim.api.nvim_set_current_win(original_window)
  end

  -- Prepare content with exit code info
  local content = {}
  if exit_code ~= 0 then
    table.insert(content, "Exit code: " .. exit_code)
    table.insert(content, "----------------------------")
  end

  -- Add output lines
  if #output > 0 then
    for _, line in ipairs(output) do
      -- Clean carriage returns and other control characters
      local cleaned_line = line:gsub("\r", ""):gsub("\x1b%[[0-9;]*m", "")
      table.insert(content, cleaned_line)
    end
  else
    table.insert(content, "(no output)")
  end

  -- Make scratch buffer modifiable to update content
  vim.api.nvim_buf_set_option(scratch_buffer, "modifiable", true)
  vim.api.nvim_buf_set_option(scratch_buffer, "readonly", false)

  -- Set buffer content
  vim.api.nvim_buf_set_lines(scratch_buffer, 0, -1, false, content)

  -- Make scratch buffer read-only again
  vim.api.nvim_buf_set_option(scratch_buffer, "readonly", true)
  vim.api.nvim_buf_set_option(scratch_buffer, "modifiable", false)

  -- Set cursor to first line of actual output (only in scratch window, don't affect current window)
  if scratch_window and vim.api.nvim_win_is_valid(scratch_window) then
    local line_count = vim.api.nvim_buf_line_count(scratch_buffer)
    local cursor_line = 1 -- Start at first line
    if exit_code ~= 0 then
      cursor_line = math.min(3, line_count) -- Line 3 is first output line when error header is shown
    end
    vim.api.nvim_win_set_cursor(scratch_window, { cursor_line, 0 })
  end
end

-- Set up the <CR> keymap for shell files
vim.keymap.set("n", "<CR>", run_shell_script, {
  buffer = true,
  desc = "Execute shell script in scratch buffer",
  silent = true,
})

-- Auto-run script when file is saved (only if scratch buffer exists)
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  buffer = 0,
  callback = function()
    -- Only auto-run if scratch buffer exists (meaning user has manually run it at least once)
    if scratch_buffer and vim.api.nvim_buf_is_valid(scratch_buffer) then
      run_shell_script()
    end
  end,
  desc = "Auto-run shell script when saved if scratch buffer exists",
})
