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
opt.winborder = 'rounded'

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
opt.foldcolumn = '0'
opt.foldmethod = 'expr'
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
opt.foldtext = 'v:lua.CustomFoldText()'

function CustomFoldText()
  local start = vim.fn.getline(vim.v.foldstart):gsub('\t', string.rep(' ', vim.bo.tabstop))
  local lines = vim.v.foldend - vim.v.foldstart + 1
  return start .. ' ··· ' .. lines .. ' lines'
end
opt.foldlevel = 99
opt.foldlevelstart = 99

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
