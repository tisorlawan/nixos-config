vim.g.disable_autocomplete = true

local opt = vim.opt

opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true

opt.number = true
opt.relativenumber = true
opt.wrap = false
opt.virtualedit = 'block'
opt.jumpoptions = 'stack'
opt.smoothscroll = true

opt.ignorecase = true
opt.smartcase = true

opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
opt.wildmode = 'longest:full,full'
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.winborder = 'single'

opt.swapfile = false
opt.undofile = true

local undodir = vim.fn.stdpath 'state' .. '/undo'
vim.fn.mkdir(undodir, 'p')
opt.undodir = undodir

opt.lazyredraw = true
opt.updatetime = 300
opt.ttimeoutlen = 0

opt.splitbelow = true
opt.splitright = true
opt.equalalways = false
opt.inccommand = 'split'

opt.showmatch = true
opt.shortmess:append 'S'
opt.title = true
opt.list = true
opt.listchars = {
  tab = '» ',
  trail = '·',
  nbsp = '␣',
  extends = '→',
  precedes = '←',
}
opt.showbreak = '↪'
-- opt.foldcolumn = '0'
-- opt.foldmethod = 'expr'
-- opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- opt.foldtext = 'v:lua.CustomFoldText()'

-- function CustomFoldText()
--   local start = vim.fn.getline(vim.v.foldstart):gsub('\t', string.rep(' ', vim.bo.tabstop))
--   local lines = vim.v.foldend - vim.v.foldstart + 1
--   return start .. ' ··· ' .. lines .. ' lines'
-- end
-- opt.foldlevel = 99
-- opt.foldlevelstart = 99

opt.path = '.,**'
opt.wildignore:append {
  '**/node_modules/**',
  '**/.git/**',
  '**/dist/**',
  '**/build/**',
  '**/__pycache__/**',
  '*.pyc',
  '*.o',
  '*.obj',
  '*.d',
}

opt.grepprg = 'rg --vimgrep --smart-case'
opt.signcolumn = 'yes:1'

if vim.g.neovide then
  vim.o.guifont = 'Berkeley Mono:h14'
  vim.g.neovide_cursor_animation_length = 0.15
  vim.g.neovide_cursor_short_animation_length = 0.015
  vim.g.neovide_scroll_animation_length = 0.05
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_cursor_cell_color_fallback = true
end
