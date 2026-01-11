-- Add <%= ... %>
vim.keymap.set("i", "<C-p>", function()
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local new_line = line:sub(1, pos[2]) .. "<%= " .. " %>" .. line:sub(pos[2] + 1)
  vim.api.nvim_set_current_line(new_line)
  vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + 4 })
end, { buffer = true, desc = "Expand .< to <%= %> in heex files" })
