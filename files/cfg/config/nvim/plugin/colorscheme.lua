local function get_color_config()
  local raw = vim.env.COLOR or vim.env.LC_COLOR

  if not raw or raw == '' then
    local color_file = io.open(vim.fn.expand '~/.color', 'r')
    if color_file then
      raw = (color_file:read '*a' or '')
      color_file:close()
    end
  end

  raw = vim.trim(raw or '')

  return raw:find 'light' and 'light' or 'dark'
end

vim.o.bg = get_color_config()

vim.pack.add {
  'https://github.com/EdenEast/nightfox.nvim',
  'https://github.com/rebelot/kanagawa.nvim',
}

if vim.g.kami_transparent == nil then
  vim.g.kami_transparent = true
end

local function setup_nightfox()
  local comment_fg = vim.o.bg == 'light' and '#ff9d00' or '#8afa1f'
  local float_bg = vim.g.kami_transparent and 'NONE' or nil

  require('nightfox').setup {
    options = {
      transparent = vim.g.kami_transparent,
      modules = { leap = false },
    },
    groups = {
      all = {
        -- Comment = { fg = comment_fg, style = 'italic,bold' },
        Comment = { fg = comment_fg, style = 'bold' },
        BlinkCmpDoc = { bg = float_bg },
        BlinkCmpDocBorder = { bg = float_bg },
        BlinkCmpMenu = { bg = float_bg },
        BlinkCmpMenuBorder = { bg = float_bg },
        FloatBorder = { bg = float_bg },
        MatchParen = { style = 'underline' },
        NormalFloat = { bg = float_bg },
        Pmenu = { bg = float_bg },
      },
    },
  }
end

setup_nightfox()

local function setup_kanagawa()
  require('kanagawa').setup {
    transparent = vim.g.kami_transparent,
  }
end

setup_kanagawa()

if vim.o.bg == 'light' then
  vim.cmd.colorscheme 'kami-light'
else
  vim.cmd.colorscheme 'kami-dark'
  -- vim.cmd.colorscheme 'kanagawa-wave'
  -- vim.cmd.colorscheme 'ocean'
  -- vim.cmd.colorscheme 'carbonfox'
end

local function toggle_transparency()
  vim.g.kami_transparent = not vim.g.kami_transparent
  local current = vim.g.colors_name or ''
  if
    current:find '^nightfox'
    or current:find '^dayfox'
    or current:find '^dawnfox'
    or current:find '^duskfox'
    or current:find '^nordfox'
    or current:find '^terafox'
    or current:find '^carbonfox'
  then
    setup_nightfox()
    vim.cmd.colorscheme(current)
  elseif current:find '^kanagawa' then
    setup_kanagawa()
    vim.cmd.colorscheme(current)
  elseif current:find '^kami' then
    vim.cmd.colorscheme(current)
  else
    vim.cmd.colorscheme(current)
  end
  vim.notify('Transparency: ' .. (vim.g.kami_transparent and 'on' or 'off'))
end

vim.keymap.set('n', '<leader>ut', toggle_transparency, { desc = 'Toggle transparency' })
