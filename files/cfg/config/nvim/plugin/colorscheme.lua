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
  'https://github.com/rebelot/kanagawa.nvim',
  'https://github.com/EdenEast/nightfox.nvim',
}

local function setup_nightfox()
  local comment_fg = vim.o.bg == 'light' and '#ff9d00' or '#8afa1f'

  require('nightfox').setup {
    options = {
      transparent = true,
      modules = { leap = false },
    },
    groups = {
      all = {
        -- Comment = { fg = comment_fg, style = 'italic,bold' },
        Comment = { fg = comment_fg, style = 'bold' },
        MatchParen = { style = 'underline' },
      },
    },
  }
end

local function setup_kanagawa()
  require('kanagawa').setup {
    transparent = true,
    commentStyle = { italic = true },
    keywordStyle = { italic = false },
    overrides = function(_)
      local comment = { fg = '#8afa1f', italic = false, bold = true }

      if vim.o.bg == 'light' then
        comment.fg = '#ff9d00'
      end

      return {
        Comment = comment,
        MatchParen = { underline = true },
      }
    end,
  }
end

setup_nightfox()
setup_kanagawa()

if vim.o.bg == 'light' then
  -- vim.cmd.colorscheme 'kanagawa'
  vim.cmd.colorscheme 'dayfox'
else
  -- vim.cmd.colorscheme 'kanagawa-lotus'
  vim.cmd.colorscheme 'nightfox'
end
