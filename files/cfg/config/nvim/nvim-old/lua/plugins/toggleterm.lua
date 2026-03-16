return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    local toggleterm = require 'toggleterm'
    local terms = require 'toggleterm.terminal'

    toggleterm.setup {
      shell = 'fish',
      size = function(term)
        if term.direction == 'horizontal' then
          return vim.o.lines * 0.3
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        elseif term.direction == 'float' then
          return math.floor(vim.o.lines * 0.6)
        end
      end,
      float_opts = {
        border = 'single',
        width = math.floor(vim.o.columns * 0.85),
        height = math.floor(vim.o.lines * 0.7),
        winblend = 0,
      },
      auto_scroll = true,
      start_in_insert = true,
      persist_size = true,
      persist_mode = true,
    }

    local map = vim.keymap.set

    local lazygit = terms.Terminal:new {
      cmd = 'lazygit',
      direction = 'float',
      id = 1001,
      hidden = true,
      float_border = 'single',
    }

    map({ 'n', 't' }, '<A-g>', function()
      lazygit:toggle()
    end, { desc = 'Toggle lazygit' })

    local floaterm = terms.Terminal:new {
      direction = 'float',
      id = 1002,
      hidden = true,
    }

    map({ 'n', 't' }, '<A-t>', function()
      local all_terms = terms.get_all()
      for _, term in ipairs(all_terms) do
        if term and term:is_open() then
          term:persist_mode()
          term:close()
          return
        end
      end
      floaterm:toggle()
    end, { desc = 'Toggle terminal (smart)' })

    vim.api.nvim_create_autocmd('TermEnter', {
      pattern = 'term://*',
      callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.foldcolumn = '0'
        vim.opt_local.signcolumn = 'no'
      end,
    })
  end,
}
