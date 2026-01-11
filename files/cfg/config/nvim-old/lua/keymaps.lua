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
map("v", "<leader>ss", ":s/\\C\\%V", { desc = "Search only in visual selection using %V atom" })
map("v", "<leader>r", '"hy:%s/\\C\\v<C-r>h//g<left><left>', { desc = "change selection" })
map("i", "<c-p>", function()
  require("fzf-lua").registers()
end, { remap = true, silent = false, desc = " and paste register in insert mode" })
map("n", "<leader>yf", ":%y<cr>", { desc = "yank current file to the clipboard buffer" })
map("n", "<leader>xc", ":!chmod +x %<cr>", { desc = "make file executable" })
map("n", "<leader>an", function()
  local current_dir = vim.fn.expand("%:h")
  if current_dir == "" then
    current_dir = "."
  end
  vim.fn.feedkeys(":e " .. current_dir .. "/", "n")
end, { desc = "Create new file in same directory" })
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

map("i", "<c-s>", "<esc>:update<cr>", { silent = true })
map("n", "<c-s>", ":update<cr>", { silent = true })

map("n", "<leader>w", ":update<cr>", { silent = true })
map("n", "<leader>Q", ":wq<cr>", { silent = true })

-- buffers
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })
map("n", "<leader><tab>", "<C-^>", { desc = "Alternative Buffer" })
map("n", "<leader>q", ":q<CR>", { desc = ":q" })

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

vim.keymap.set("n", "<C-x><C-n>", function()
  local current_file = vim.fn.expand("%")
  if current_file == "" then
    print("No file is currently open")
    return
  end

  local current_dir = vim.fn.fnamemodify(current_file, ":h")
  local current_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Use vim.fn.input with completion instead of vim.ui.input
  local filename = vim.fn.input("Open: ", current_dir .. "/", "file")

  if filename and filename ~= "" then
    -- Check if file already exists
    if vim.fn.filereadable(filename) == 1 then
      -- File exists, just open it (don't copy content)
      vim.cmd("edit " .. vim.fn.fnameescape(filename))
    else
      -- File doesn't exist, create it with current buffer content
      vim.cmd("edit " .. vim.fn.fnameescape(filename))
      vim.api.nvim_buf_set_lines(0, 0, -1, false, current_content)
    end
  end
end, { desc = "Create new file with current buffer content or open existing file" })

-- movement in insert mode
map("i", "<c-l>", "<right>")
map("i", "<c-h>", "<left>")
map("i", "<c-j>", "<down>")
map("i", "<c-k>", "<up>")
map("i", "<m-h>", "<esc>I")
map("i", "<m-l>", "<end>")

map("v", "g<c-b>", "g<c-a>") -- create sequence of numbers

-- vim.cmd("syntax off | colorscheme retrobox | highlight Normal guifg=#f0f0f0 guibg=#282828")
vim.keymap.set("n", "<space>y", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end)
vim.keymap.set("n", "<space><space>", function()
  vim.ui.input({}, function(c)
    if c and c ~= "" then
      vim.cmd("noswapfile vnew")
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.systemlist(c))
    end
  end)
end)

-- Function to add ripgrep results to quickfix
local function add_rg_result_to_quickfix(output, search_term)
  vim.fn.setqflist({}, "r") -- Clear existing quickfix
  for _, line in ipairs(output) do
    -- Parse ripgrep --vimgrep format: file:line:col:text
    local file, lnum, col, text = line:match("([^:]+):(%d+):(%d+):(.*)")
    if file and lnum and col and text then
      vim.fn.setqflist({
        {
          filename = file,
          lnum = tonumber(lnum),
          col = tonumber(col),
          text = text,
        },
      }, "a") -- Append to quickfix
    end
  end
  -- Set custom title if search term is provided
  if search_term then
    vim.fn.setqflist({}, "a", { title = "rg: '" .. search_term .. "'" })
  end
  vim.cmd("copen")
end

-- Make function available globally for VimScript
_G.handle_rg_result = add_rg_result_to_quickfix

-- Define global VimScript function for parsing and searching
vim.cmd([[
  function! ParseAndSearch(text)
    let result = a:text

    " Check if result contains -g delimiter
    let parts = split(result, ' -g ', 1)
    if len(parts) > 1
      " Has -g flags
      let search_term = parts[0]
      let additional_flags = ''
      for i in range(1, len(parts) - 1)
        let additional_flags .= ' -g ' . parts[i]
      endfor

      " Check for mode flags (r: for regex, i: for case-insensitive)
      let mode_flags = ''
      let actual_term = search_term

      if search_term =~ '^[ri]*:'
        let flags = matchstr(search_term, '^[ri]*')
        let actual_term = substitute(search_term, '^[ri]*:', '', '')

        if flags =~ 'i'
          let mode_flags .= ' --ignore-case'
        endif

        if flags =~ 'r'
          " Regex mode - don't add --fixed-strings
        else
          let mode_flags .= ' --fixed-strings'
        endif
      else
        let mode_flags = ' --fixed-strings'
      endif

      let escaped_term = shellescape(actual_term)
      let cmd = "rg --vimgrep" . mode_flags . additional_flags . " -- " . escaped_term
      let search_term = actual_term
    else
      " No -g flags, check for mode flags
      let mode_flags = ''
      let actual_term = result

      if result =~ '^[ri]*:'
        let flags = matchstr(result, '^[ri]*')
        let actual_term = substitute(result, '^[ri]*:', '', '')

        if flags =~ 'i'
          let mode_flags .= ' --ignore-case'
        endif

        if flags =~ 'r'
          " Regex mode - don't add --fixed-strings
        else
          let mode_flags .= ' --fixed-strings'
        endif
      else
        let mode_flags = ' --fixed-strings'
      endif

      let escaped_term = shellescape(actual_term)
      let cmd = "rg --vimgrep" . mode_flags . " -- " . escaped_term
      let search_term = actual_term
    endif

    let output = systemlist(cmd)
    lua handle_rg_result(vim.fn.eval('output'), vim.fn.eval('search_term'))
  endfunction
]])

-- Function to perform ripgrep search with text
local function do_ripgrep_search(text)
  if text == "" then
    return
  end
  vim.cmd("call ParseAndSearch(" .. vim.fn.string(text) .. ")")
end

-- -- <leader>ll - Search prompt with C-n toggle
-- vim.keymap.set("n", "<leader>ll", function()
--   vim.cmd([[
--     function! RipgrepSearch()
--       " Set up temporary C-n mapping for command line
--       cnoremap <C-n> <C-c>:call RipgrepRawMode()<CR>
--
--       let result = input('Search: ', '')
--
--       " Clean up mapping
--       cunmap <C-n>
--
--       if result != ''
--         call ParseAndSearch(result)
--       endif
--     endfunction
--
--     function! RipgrepRawMode()
--       let cmd = input('', 'rg --vimgrep --fixed-strings ')
--       if cmd != ''
--         let output = systemlist(cmd)
--         let search_term = matchstr(cmd, "'\\zs[^']*\\ze'")
--         if search_term == ''
--           let search_term = 'raw_search'
--         endif
--         lua handle_rg_result(vim.fn.eval('output'), vim.fn.eval('search_term'))
--       endif
--     endfunction
--   ]])
--
--   vim.cmd("call RipgrepSearch()")
-- end)
--
-- -- <leader>l + motion - search text object
-- vim.keymap.set("n", "<leader>l", function()
--   vim.o.operatorfunc = "v:lua.ripgrep_operator"
--   return "g@"
-- end, { expr = true })
--
-- -- Operator function for <leader>l + motion
-- _G.ripgrep_operator = function(type)
--   local saved_reg = vim.fn.getreg('"')
--   local saved_regtype = vim.fn.getregtype('"')
--
--   if type == "char" then
--     vim.cmd("silent normal! `[v`]y")
--   elseif type == "line" then
--     vim.cmd("silent normal! `[V`]y")
--   elseif type == "block" then
--     vim.cmd("silent normal! `[<C-v>`]y")
--   else
--     return
--   end
--
--   local text = vim.fn.getreg('"')
--   vim.fn.setreg('"', saved_reg, saved_regtype)
--
--   -- Clean up the text
--   text = string.gsub(text, "\n", " ")
--   text = string.gsub(text, "%s+", " ")
--   text = string.gsub(text, "^%s*(.-)%s*$", "%1")
--
--   if text ~= "" then
--     local escaped_text = vim.fn.shellescape(text)
--     local cmd = "rg --vimgrep --fixed-strings -- " .. escaped_text
--     local output = vim.fn.systemlist(cmd)
--     add_rg_result_to_quickfix(output, text)
--   end
-- end
--
-- -- <leader>lw - search current word
-- vim.keymap.set("n", "<leader>lw", function()
--   local current_word = vim.fn.expand("<cword>")
--   if current_word ~= "" then
--     do_ripgrep_search(current_word)
--   end
-- end)
--
-- -- <leader>lW - search current WORD
-- vim.keymap.set("n", "<leader>lW", function()
--   local current_word = vim.fn.expand("<cWORD>")
--   if current_word ~= "" then
--     do_ripgrep_search(current_word)
--   end
-- end)
--
-- -- <cr>S - buffer + quickfix
-- vim.keymap.set("n", "<leader>L", function()
--   vim.ui.input({ prompt = "Search: ", default = "rg --vimgrep " }, function(c)
--     if c and c ~= "" then
--       -- Create new buffer
--       vim.cmd("noswapfile vnew")
--       vim.bo.buftype = "nofile"
--       vim.bo.bufhidden = "wipe"
--
--       -- Get command output
--       local output = vim.fn.systemlist(c)
--
--       -- Add to buffer
--       vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
--
--       -- Extract search term from command
--       local search_term = c:match("'([^']*)'") or c:match("%S+$") or "unknown"
--       -- Add to quickfix
--       add_rg_result_to_quickfix(output, search_term)
--     end
--   end)
-- end)
--
-- -- Visual mode <cr>s - search selected text
-- vim.keymap.set("v", "<leader>l", function()
--   -- Use a more reliable method to get the selected text
--   local mode = vim.fn.mode()
--   if mode == "v" or mode == "V" or mode == "\22" then -- \22 is visual block mode
--     -- Store current register
--     local old_reg = vim.fn.getreg("z")
--     local old_regtype = vim.fn.getregtype("z")
--
--     -- Yank selection to register z
--     vim.cmd('silent normal! "zy')
--
--     -- Get the yanked text
--     local selected_text = vim.fn.getreg("z")
--
--     -- Restore the register
--     vim.fn.setreg("z", old_reg, old_regtype)
--
--     -- Clean up the text
--     selected_text = string.gsub(selected_text, "\n", " ")
--     selected_text = string.gsub(selected_text, "%s+", " ")
--     selected_text = string.gsub(selected_text, "^%s*(.-)%s*$", "%1")
--
--     if selected_text ~= "" then
--       -- Store original text for title
--       local original_text = selected_text
--
--       -- Use proper shell escaping
--       local escaped_text = vim.fn.shellescape(selected_text)
--       local cmd = "rg --vimgrep --fixed-strings -- " .. escaped_text
--       local output = vim.fn.systemlist(cmd)
--       add_rg_result_to_quickfix(output, original_text)
--     end
--   end
-- end)

-- <leader>* - search current word in current file
vim.keymap.set("n", "<leader>*", function()
  local current_word = vim.fn.expand("<cword>")
  if current_word ~= "" then
    local current_file = vim.fn.expand("%:p")
    if current_file ~= "" then
      local escaped_word = vim.fn.shellescape(current_word)
      local escaped_file = vim.fn.shellescape(current_file)
      local cmd = "rg --vimgrep --fixed-strings -- " .. escaped_word .. " " .. escaped_file
      local output = vim.fn.systemlist(cmd)
      add_rg_result_to_quickfix(output, current_word)
    else
      print("No file to search in")
    end
  else
    print("No word under cursor")
  end
end)

-- Open hover documentation in vertical scratch buffer
map("n", "<leader>K", function()
  -- Get hover information
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result, ctx, config)
    if err or not result or not result.contents then
      print("No hover information available")
      return
    end

    -- Create vertical scratch buffer
    vim.cmd("noswapfile vnew")
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.filetype = "markdown" -- Set filetype for syntax highlighting

    -- Function to clean HTML entities
    local function clean_html_entities(text)
      text = text:gsub("&nbsp;", " ")
      text = text:gsub("&lt;", "<")
      text = text:gsub("&gt;", ">")
      text = text:gsub("&amp;", "&")
      text = text:gsub("&quot;", '"')
      text = text:gsub("&#39;", "'")
      text = text:gsub("\\_", "_")
      return text
    end

    -- Extract content from hover result
    local content = {}
    if type(result.contents) == "string" then
      -- Simple string content
      local cleaned = clean_html_entities(result.contents)
      for line in cleaned:gmatch("[^\n]+") do
        table.insert(content, line)
      end
    elseif result.contents.value then
      -- MarkupContent format
      local cleaned = clean_html_entities(result.contents.value)
      for line in cleaned:gmatch("[^\n]+") do
        table.insert(content, line)
      end
    elseif type(result.contents) == "table" then
      -- Array of MarkedString or MarkupContent
      for _, item in ipairs(result.contents) do
        if type(item) == "string" then
          local cleaned = clean_html_entities(item)
          for line in cleaned:gmatch("[^\n]+") do
            table.insert(content, line)
          end
        elseif item.value then
          local cleaned = clean_html_entities(item.value)
          for line in cleaned:gmatch("[^\n]+") do
            table.insert(content, line)
          end
        end
        table.insert(content, "") -- Add empty line between items
      end
    end

    -- Set buffer content
    vim.api.nvim_buf_set_lines(0, 0, -1, false, content)

    -- Make buffer read-only
    vim.bo.readonly = true
    vim.bo.modifiable = false
  end)
end, { desc = "Open hover info in vertical scratch buffer" })
