local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "snacks_win",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  -- pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  pattern = { "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "fzf" },
  callback = function(event)
    -- remove small delay in <C-c>
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("t", "<C-c>", "<C-c>", { buffer = event.buf, silent = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function(event)
    vim.keymap.set("n", "q", ":q<cr>", { buffer = event.buf, silent = true })
  end,
})

-- disable semantic highlighting
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    vim.api.nvim_set_hl(0, "SnippetTabstop", { link = "NONE" })
  end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  pattern = "*",
  command = "silent !zellij action switch-mode normal",
})

local function disable_tsx_link_label_underline()
  if not vim.api.nvim_get_hl then
    return
  end

  local hl
  for _, name in ipairs({ "@markup.link", "Underlined" }) do
    local ok, value = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and value then
      hl = vim.deepcopy(value)
      break
    end
  end

  if not hl then
    return
  end

  hl.underline = false
  if type(hl.cterm) == "table" then
    hl.cterm.underline = false
  end
  hl.undercurl = nil
  hl.underdotted = nil
  hl.underdashed = nil
  hl.underdouble = nil
  hl.underdrawn = nil
  hl.link = nil
  hl.default = nil

  vim.api.nvim_set_hl(0, "@markup.link.label.tsx", hl)
end

local tsx_link_label_group = augroup("tsx_link_label")

vim.api.nvim_create_autocmd("VimEnter", {
  group = tsx_link_label_group,
  callback = disable_tsx_link_label_underline,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = tsx_link_label_group,
  callback = function()
    vim.schedule(disable_tsx_link_label_underline)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = tsx_link_label_group,
  pattern = { "typescriptreact" },
  callback = function()
    vim.schedule(disable_tsx_link_label_underline)
  end,
})

-- ------------------------------------------------- --
-- Keep the cursor position when yanking
local cursorPreYank

vim.keymap.set({ "n", "x" }, "y", function()
  cursorPreYank = vim.api.nvim_win_get_cursor(0)
  return "y"
end, { expr = true })

vim.keymap.set("n", "Y", function()
  cursorPreYank = vim.api.nvim_win_get_cursor(0)
  return "y$"
end, { expr = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    if vim.v.event.operator == "y" and cursorPreYank then
      vim.api.nvim_win_set_cursor(0, cursorPreYank)
    end
  end,
})
