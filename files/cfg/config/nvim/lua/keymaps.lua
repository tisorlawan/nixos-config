local utils = require("utils")
local map = vim.keymap.set

map({ "i" }, "<C-g>", "<ESC>")

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

map("n", "<esc>", "<cmd>nohlsearch<cr>")
map("n", "<m-n>", "<cmd>bnext<cr>")
map("n", "<m-p>", "<cmd>bprevious<cr>")

map("n", "'", "`")
map("n", "`", "'")

map("v", "x", '"_dP')

map("n", "gx", "gx", { desc = "Browse" })
map("v", "gx", "gx", { desc = "Browse" })

map("n", "gV", "`[v`]", { desc = "Reselect pasted text" })
-- map({ "n", "v" }, "mp", '"0p', { desc = "paste from 0 register" })
map("n", "n", "nzzzv", { desc = "keep cursor centered" })
map("n", "N", "Nzzzv", { desc = "keep cursor centered" })
map("n", "<C-M-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
map("n", "<C-M-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
map("v", "<C-M-j>", ":m '>+1<CR>gv=gv", { desc = "Move Line Down in Visual Mode", silent = true })
map("v", "<C-M-k>", ":m '<-2<CR>gv=gv", { desc = "Move Line Up in Visual Mode", silent = true })
map("v", "<leader>ss", ":s/\\%V", { desc = "Search only in visual selection using %V atom" })
map("v", "<leader>r", '"hy:%s/\\v<C-r>h//g<left><left>', { desc = "change selection" })
map("i", "<c-p>", function()
  require("fzf-lua").registers()
end, { remap = true, silent = false, desc = " and paste register in insert mode" })
map("n", "<leader>yf", ":%y<cr>", { desc = "yank current file to the clipboard buffer" })
map("n", "<leader>xc", ":!chmod +x %<cr>", { desc = "make file executable" })
map(
  "n",
  "<leader>pf",
  ':let @+ = expand("%:p")<cr>:lua print("Copied path to: " .. vim.fn.expand("%:p"))<cr>',
  { desc = "Copy current file name and path", silent = true }
)
map("n", "<leader>pF", function()
  print(vim.fn.expand("%:p"))
end, { desc = "Print current file path", silent = true })
map(
  "n",
  "<leader>pn",
  ':let @+ = expand("%:.")<cr>:lua print("Copied relative path: " .. vim.fn.expand("%:."))<cr>',
  { desc = "Copy current file path relative to cwd", silent = true }
)
map(
  "n",
  "<leader>pN",
  ':let @+ = expand("%:t")<cr>:lua print("Copied file name: " .. vim.fn.expand("%:t"))<cr>',
  { desc = "Copy file name", silent = true }
)

map("i", "<c-x><c-s>", "<esc>:update<cr>", { silent = true })
map("n", "<c-x><c-s>", ":update<cr>", { silent = true })

map("n", "<leader>w", ":update<cr>", { silent = true })
map("n", "<leader>Q", ":wq<cr>", { silent = true })

-- buffers
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })
map("n", "<leader><tab>", "<C-^>", { desc = "Alternative Buffer" })

map("n", "<leader>pp", ":Lazy<cr>", { desc = "Lazy", silent = true })
map("n", "<Leader>pt", utils.get_linters, { desc = "lint progress", silent = true })
map("n", "<Leader>pi", ":LspInfo<cr>", { desc = "lsp info", silent = true })
map("n", "<Leader>pr", ":LspRestart<cr>", { desc = "lsp restart", silent = true })
map("n", "<Leader>pm", ":Mason<cr>", { desc = "Mason", silent = true })
map("n", "<Leader>pc", ":ConformInfo<cr>", { desc = "conform info", silent = true })
-- map("n", "<Leader>ud", utils.toggle_diagnostics, { desc = "toggle diagnostics" })

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })

-- list
map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })
map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

map("n", "cn", ":cnext<CR>", { silent = true })
map("n", "cp", ":cprev<CR>", { silent = true })
map("n", "co", ":copen<CR>", { silent = true })
map("n", "cq", utils.close_diagnostics, { desc = "close diagnostics", silent = true })
map("n", "cu", utils.jumps_to_qf, { desc = "jumps to qf", silent = true })

-- notifications
map("n", "<leader>q", function()
  require("noice").cmd("dismiss")
end, { desc = "Dismiss" })

-- movement in insert mode
map("i", "<c-l>", "<right>")
map("i", "<c-h>", "<left>")
map("i", "<c-j>", "<down>")
map("i", "<c-k>", "<up>")
map("i", "<m-h>", "<esc>I")
map("i", "<m-l>", "<end>")

map("v", "g<c-b>", "g<c-a>") -- create sequence of numbers

-- vim.cmd("syntax off | colorscheme retrobox | highlight Normal guifg=#f0f0f0 guibg=#282828")
vim.keymap.set('n', '<space>y', function() vim.fn.setreg('+', vim.fn.expand('%:p')) end)
vim.keymap.set("n", "<cr><cr>", function() vim.ui.input({}, function(c) if c and c~="" then 
  vim.cmd("noswapfile vnew") vim.bo.buftype = "nofile" vim.bo.bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.systemlist(c)) end end) end)

-- Function to add ripgrep results to quickfix
local function add_rg_result_to_quickfix(output)
  vim.fn.setqflist({}, "r") -- Clear existing quickfix
  for _, line in ipairs(output) do
    -- Parse ripgrep --vimgrep format: file:line:col:text
    local file, lnum, col, text = line:match("([^:]+):(%d+):(%d+):(.*)")
    if file and lnum and col and text then
      vim.fn.setqflist({{
        filename = file,
        lnum = tonumber(lnum),
        col = tonumber(col),
        text = text
      }}, "a") -- Append to quickfix
    end
  end
  vim.cmd("copen")
end

-- <cr>s - quickfix only
vim.keymap.set("n", "<cr>s", function() 
  vim.ui.input({ prompt = "Search: ", default = "rg --vimgrep " }, function(c) 
    if c and c ~= "" then 
      local output = vim.fn.systemlist(c)
      add_rg_result_to_quickfix(output)
    end 
  end) 
end)

-- <cr>S - buffer + quickfix
vim.keymap.set("n", "<cr>S", function() 
  vim.ui.input({ prompt = "Search: ", default = "rg --vimgrep " }, function(c) 
    if c and c ~= "" then 
      -- Create new buffer
      vim.cmd("noswapfile vnew") 
      vim.bo.buftype = "nofile" 
      vim.bo.bufhidden = "wipe"
      
      -- Get command output
      local output = vim.fn.systemlist(c)
      
      -- Add to buffer
      vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
      
      -- Add to quickfix
      add_rg_result_to_quickfix(output)
    end 
  end) 
end)

-- Visual mode <cr>s - search selected text
vim.keymap.set("v", "<cr>s", function()
  -- Use a more reliable method to get the selected text
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then -- \22 is visual block mode
    -- Store current register
    local old_reg = vim.fn.getreg("z")
    local old_regtype = vim.fn.getregtype("z")

    -- Yank selection to register z
    vim.cmd('silent normal! "zy')

    -- Get the yanked text
    local selected_text = vim.fn.getreg("z")

    -- Restore the register
    vim.fn.setreg("z", old_reg, old_regtype)

    -- Clean up the text
    selected_text = string.gsub(selected_text, "\n", " ")
    selected_text = string.gsub(selected_text, "%s+", " ")
    selected_text = string.gsub(selected_text, "^%s*(.-)%s*$", "%1")

    if selected_text ~= "" then
      -- Escape for shell
      selected_text = vim.fn.shellescape(selected_text)

      local cmd = "rg --vimgrep " .. selected_text
      local output = vim.fn.systemlist(cmd)
      add_rg_result_to_quickfix(output)
    end
  end
end)
