local M = {}

function M.close_diagnostics()
  local windows = vim.api.nvim_list_wins()
  for _, win in ipairs(windows) do
    vim.api.nvim_win_call(win, function()
      if vim.bo.buftype == "quickfix" then
        vim.cmd("lclose")
      elseif vim.bo.buftype == "locationlist" then
        vim.cmd("cclose")
      elseif vim.bo.buftype == "help" then
        vim.cmd("bdelete")
        ---@diagnostic disable-next-line: param-type-mismatch
      elseif vim.fn.bufname("%") == "Trouble" then
        vim.cmd("bdelete")
      end
    end)
  end

  vim.cmd("cclose")
end

function M.jumps_to_qf()
  local jumplist, _ = unpack(vim.fn.getjumplist())
  local qf_list = {}
  for _, v in pairs(jumplist) do
    if vim.fn.bufloaded(v.bufnr) == 1 then
      table.insert(qf_list, {
        bufnr = v.bufnr,
        lnum = v.lnum,
        col = v.col,
        text = vim.api.nvim_buf_get_lines(v.bufnr, v.lnum - 1, v.lnum, false)[1],
      })
    end
  end
  vim.fn.setqflist(qf_list, " ")
  vim.cmd("copen")
end

function M.toggle_diagnostics()
  if vim.diagnostic.is_disabled() then
    vim.diagnostic.enable()
    print("enabled diagnostic")
  else
    vim.diagnostic.disable()
    print("disable diagnostic")
  end
end

function M.get_linters()
  local linters = require("lint").get_running()
  if #linters == 0 then
    print("-- No linters --")
  else
    print("Linters: " .. table.concat(linters, ", "))
  end
end

function M.os_exec(cmd, raw)
  local handle = assert(io.popen(cmd, "r"))
  local output = assert(handle:read("*a"))

  handle:close()

  if raw then
    return output
  end

  output = string.gsub(string.gsub(string.gsub(output, "^%s+", ""), "%s+$", ""), "[\n\r]+", " ")

  return output
end

function M.trim(s)
  return s:gsub("^%s*(.-)%s*$", "%1")
end

function M.file_exists(filepath)
  local file = io.open(filepath, "r")
  if file then
    file:close()
    return true
  end
  return false
end

function M.contains(sequence, element)
  for _, value in ipairs(sequence) do
    if value == element then
      return true
    end
  end
  return false
end

function M.buf_set_keymap_add_colon()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.keymap.set("i", "<C-d>", "<End>;", { noremap = true, silent = true, buffer = bufnr })
end


function M.is_nixos()
  if M.os_exec("uname") == "Linux" then
    local release_name = M.os_exec("cat /etc/os-release | grep '^NAME=' | cut -d'=' -f2")
    if release_name == "NixOS" then
      return true
    end
    return false
  end
end

function M.remove_item_from_array(table, item)
  local i = 1
  while i <= #table do
    if table[i] == item then
      table[i] = nil
    else
      i = i + 1
    end
  end
end

return M
