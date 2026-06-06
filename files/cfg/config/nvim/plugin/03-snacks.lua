local map = vim.keymap.set

vim.pack.add {
  'https://github.com/folke/snacks.nvim',
  'https://github.com/folke/edgy.nvim',
  'https://github.com/folke/todo-comments.nvim',
}

local Snacks = require 'snacks'

local frieren_headers = {
  [[
⠀⠀⠀⠀⠀⠀⢀⡴⢾⣶⣴⠚⣫⠏⠉⠉⠛⠛⢭⡓⢶⣶⠶⣦⡀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣰⠋⡀⣠⠟⢁⣾⠇⠀⣀⣷⠀⠀⠓⣝⠂⠙⣆⢄⢻⡞⢢⠀⠀⠀
⠀⠀⠀⠀⢠⡇⢸⢡⠃⢠⡞⠁⠀⣰⡟⠉⢦⣄⠀⠈⢆⠀⢻⣾⡄⢧⢸⠀⠀⠀
⠀⠀⠀⠀⢸⠀⡇⡌⠀⡞⠀⢀⣴⡋⠀⠀⠀⣙⣷⡀⠘⡄⠘⣿⣧⢸⣼⣥⠀⠀
⣀⣀⣀⣀⣞⣰⠁⡇⠀⣧⢴⡛⠛⠁⠀⠀⠀⠉⠉⡙⡦⡇⠀⣿⣸⣼⣿⣇⣀⣀
⠳⢽⣷⠺⡟⡿⣯⡇⠰⣧⢩⣭⣥⠀⠀⠀⠀⢠⣭⣥⠁⡀⠀⣿⡟⣴⠶⢁⡨⠊
⠀⠀⠉⢳⢦⣅⠘⣿⣄⢿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡇⢀⣏⣳⡇⢴⡞⠁⠀
⠀⠀⠀⣼⢸⡅⢹⣿⣿⣾⣟⠀⠀⠠⣀⢄⡠⠀⠀⠠⡚⣿⡿⣿⢻⠁⢹⣷⡀⠀
⠀⠀⠸⡏⠸⡇⢼⣿⡿⠟⠛⠓⣦⣄⣀⣀⣀⣀⡤⠴⠿⢿⡟⠛⠺⣦⣬⣗⠀⠀
⠀⠀⢰⡇⠀⡇⠸⡏⠀⠀⢰⠋⠙⠛⠛⠉⠉⢹⠀⠀⠀⠀⡇⠀⠀⣿⣿⣿⣟⡃
⠀⡐⣾⠀⡀⢹⠀⣿⣄⠀⢸⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⢠⣇⠀⠀⣿⣿⣿⣛⡃
⠀⣾⣿⠀⡇⠘⡄⢸⣿⠆⠈⡇⠀⠀⠀⠀⠈⢉⠃⠀⣰⡾⠻⠃⢰⣿⣿⣛⡋⠀
⠀⣿⣿⡆⢷⠀⢧⠈⣿⠤⠤⣇⠀⠀⠀⠀⢀⣸⣠⢾⠟⠓⡶⢤⣾⣿⣿⣟⣓⠀]],
  [[
⠀⠀⠀⠀⠀⠀⢀⡴⢾⣶⣴⠚⣫⠏⠉⠉⠛⠛⢭⡓⢶⣶⠶⣦⡀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣰⠋⡀⣠⠟⢁⣾⠇⠀⣀⣷⠀⠀⠓⣝⠂⠙⣆⢄⢻⡞⢢⠀⠀⠀
⠀⠀⠀⠀⢠⡇⢸⢡⠃⢠⡞⠁⠀⣰⡟⠉⢦⣄⠀⠈⢆⠀⢻⣾⡄⢧⢸⠀⠀⠀
⠀⠀⠀⠀⢸⠀⡇⡌⠀⡞⠀⢀⣴⡋⠀⠀⠀⣙⣷⡀⠘⡄⠘⣿⣧⢸⣼⣥⠀⠀
⣀⣀⣀⣀⣞⣰⠁⡇⠀⣧⠴⠛⠛⠁⠀⠀⠀⠉⠉⠙⠦⡇⠀⣿⣸⣼⣿⣇⣀⣀
⠳⢽⣷⠺⡟⡿⣯⡇⠰⣧⠠⣿⡷⠂⠀⠀⠀⠐⣾⠷⠀⡀⠀⣿⡟⣴⠶⢁⡨⠊
⢀⣀⡉⢳⢦⣅⠘⣿⣄⢿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡇⢀⣏⣳⣿⣴⡞⠈⠀
⣟⣿⣷⣼⢸⡅⢹⣿⣿⣾⣟⠀⠀⢠⣀⣄⣠⠀⠀⢠⣾⣿⡿⣿⢻⠁⢹⣷⡀⠀
⠿⠿⠿⡏⠸⡇⢼⣿⡿⠟⠛⠓⣦⣄⣀⣀⣀⣀⡤⠴⠿⢿⡟⠛⠺⣦⣬⣗⠀⠀
⠀⠀⢰⡇⠀⡇⠸⡏⠀⠀⢰⠋⠙⠛⠛⠉⠉⢹⠀⠀⠀⠀⡇⠀⠀⣿⣿⣿⣿⣿
⢀⡐⣾⠀⡀⢹⠀⣿⣄⠀⢸⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⢠⣇⠀⠀⣿⣿⣿⣿⣿
⣸⣿⣿⠀⡇⠘⡄⢸⣿⠆⠈⡇⠀⠀⠀⠀⠈⢉⠃⠀⣰⡾⠻⠃⢰⣿⣿⣿⣿⡇
⣿⣿⣿⡆⢷⠀⢧⠈⣿⠤⠤⣇⠀⠀⠀⠀⢀⣸⣠⢾⠟⠓⡶⢤⣾⣿⣿⣿⣿⣷]],
  [[
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣿⣿⣿⡿⢿⡿⠿⠿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⡿⣿⣿
⣿⣿⣿⣿⠿⠿⢿⣿⣿⠟⣋⣭⣶⣶⣞⣿⣶⣶⣶⣬⣉⠻⣿⣿⡿⣋⣉⠻⣿⣿⣿
⣿⢻⣿⠃⣤⣤⣢⣍⣴⣿⢋⣵⣿⣿⣿⣿⣷⣶⣝⣿⣿⣧⣄⢉⣜⣥⣜⢷⢹⢇⢛
⡏⡦⡁⡸⢛⡴⢣⣾⢟⣿⣿⣿⢟⣾⣧⣙⢿⣿⣿⣿⣿⣿⣿⣿⢩⢳⣞⢿⡏⢷⣾
⣷⣵⡇⣗⡾⢁⣾⣟⣾⣿⡿⣻⣾⣿⣿⣿⡎⠛⡛⢿⣿⡟⣿⣿⡜⡜⢿⡌⠇⢾⣿
⣿⣿⠁⣾⠏⣾⣿⣿⣽⣑⣺⣥⣿⣿⣿⣿⣷⣶⣦⣖⢝⢿⣿⣿⣿⡀⠹⣿⣼⢸⣿
⣿⣿⢰⡏⢡⣿⣿⠐⣵⠿⠛⠛⣿⣿⣿⣿⣿⠍⠚⢙⠻⢦⣼⣿⣿⠁⣄⣿⣿⠘⣿
⣿⣿⢸⢹⢈⣿⣿⠘⣡⡞⠉⡀⢻⣿⣿⣿⣿⢃⠠⢈⢳⣌⣩⣿⣿⠰⠿⢼⣿⠀⣿
⣿⠿⣘⠯⠌⡟⣿⡟⣾⣇⢾⡵⣹⣟⣿⣿⣿⣮⣓⣫⣿⣟⢿⣿⢿⡾⡹⢆⣦⣤⢹
⣅⣛⠶⠽⣧⣋⠳⡓⢿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣫⣸⠏⡋⠷⣛⣫⡍⣶⣿
⣿⡿⢸⢳⣶⣶⠀⡇⣬⡛⠿⣿⣿⣿⣿⣿⣿⣿⠿⢟⣉⣕⡭⠀⢺⣸⣽⢻⡅⣿⣿
⣿⡇⣾⡾⣰⡯⠀⡗⣯⣿⣽⡶⠶⠂⢠⣾⣿⠐⠚⠻⢯⣿⠇⠎⡀⣳⣿⣼⡃⣿⣿
⣿⡇⣟⣇⡟⣧⠀⡗⣿⣿⡿⢡⢖⣀⠼⢟⣻⣤⣔⢦⢸⣿⢀⢆⢡⣿⣯⢹⡃⣿⣿]],
  [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠠⠀⠠⠀⠄⠠⠠⠀⠤⠀⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠐⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠑⠀⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⠀⠀⢀⠔⠁⠀⠀⠀⢀⠤⠀⠀⠀⠀⠀⠀⠠⢀⠀⠀⠀⠀⡈⠢⡀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⠔⠁⠤⠑⡖⠁⠀⠀⠀⠀⠔⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠑⢄⠀⠀⠈⠠⡘⢖⠁⠈⠐⡄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢠⠂⡐⠀⠀⡊⠀⠀⠀⠀⠀⡡⠒⠀⠀⠀⢀⠆⢣⠀⠀⠀⠀⠀⢄⠡⡀⠀⠀⠈⢌⢆⠂⠄⠈⢢⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠆⠐⠀⠀⡜⢀⠀⠀⠀⠀⡔⠀⠀⠀⠀⡠⠃⠀⠀⠣⡀⠀⠀⠀⠀⠐⢵⡀⠀⠀⠈⡌⡂⠈⠆⠀⢢⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⡘⠀⠉⠀⢀⡇⠌⠀⠀⠀⡔⠀⠀⠀⣀⠖⠀⠀⠀⠀⠀⠈⠦⣀⠀⠀⠀⠀⠇⠀⠀⠀⠘⢧⠀⠸⠀⠀⢇⠀⠀⠀⠀⠀
⠀⠀⠀⠀⡁⠀⠀⠀⢸⢢⠁⠀⠀⠐⠀⠀⡠⠚⠀⠉⠂⠀⠀⠀⠀⠀⠘⠀⠸⢅⠀⠀⠸⠀⠀⠀⠀⣿⡀⠀⡇⠀⠈⠄⠀⠀⠀⠀
⢰⠠⣤⠄⠸⠀⠀⠀⣀⡜⡌⠀⠀⠀⢸⠉⣅⣤⣀⣒⠄⠀⠀⠀⠀⠀⠀⠠⢐⣠⣤⣤⣱⠒⡇⠀⠀⠀⢸⡡⠀⠃⠤⠤⢤⡄⠖⢒⠆
⠀⠱⢄⠈⢅⠒⢐⠠⢄⠈⡇⠀⠀⠐⢻⠟⢋⠟⢋⠙⣗⡄⠀⠀⠀⠀⠀⢐⡟⢉⠙⢮⠙⢷⡟⠀⠀⠀⢸⢀⠄⠂⢠⠍⠀⢀⠄⠊⠀
⠀⠀⢀⠕⠠⡀⠈⠂⠣⠀⠆⠀⠀⠀⠸⠂⢸⣀⠻⢇⢸⠀⠀⠀⠀⠀⠀⠸⣀⠿⢄⢸⠀⢁⠃⠀⠀⠠⢸⢨⠀⠀⠀⡠⠔⢡⠀⠀⠀
⠀⢀⠌⠀⠀⠑⠠⡀⠀⠂⡆⡆⠀⠀⡀⡆⠈⢫⢀⠸⠊⠀⠀⠀⠀⠀⠀⠀⠫⢄⠨⠊⠀⡘⠀⠀⠀⢰⢸⠈⢀⡠⠐⠁⠀⠈⡆⠀⠀
⢀⠎⢀⠎⠀⠀⡘⠘⠈⠐⢣⢰⡀⠀⠸⣜⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⢥⠆⠀⡠⢨⠎⠉⢡⠐⠀⠀⠀⠀⢰⠀⠀]],
  [[
⡀⡀⡀⡀⡀⡀⢠⣾⣿⠞⠫⣿⣿⣿⣿⣿⡻⢿⣿⣿⣶⣤⣠⣴⣲⣤⡀⡀⡀⡀⡀
⡀⡀⡀⡀⡀⡀⡠⣟⡟⢁⣴⣾⣿⡟⢿⣿⣿⣧⡐⠹⣿⣿⣿⣿⣿⣿⣿⣿⡆⡀⡀⡀
⡀⡀⡀⡀⡀⣼⣿⡇⣴⣿⣿⡿⡏⣱⡸⢿⣿⣿⣷⣦⢹⣿⣿⣿⣿⣿⣿⣿⣿⡀⡀⡀
⡀⡀⡀⡀⣼⣿⡟⣸⣿⣿⠏⢀⣼⣿⣧⢂⠻⣿⣿⣿⡆⣿⣿⣿⣿⣿⣿⣿⣿⡇⡀⡀
⡀⡀⡀⢠⣻⣿⠇⠫⠛⡀⡐⣿⣿⣿⣿⡷⡀⠙⠻⣻⣷⢹⣿⣿⣿⡿⣯⣿⣿⣿⡀⡀
⡀⡀⡀⢸⣿⣿⢠⣴⣾⣶⠾⣿⣿⣿⣿⣿⢶⣦⣄⠝⠛⢸⣿⣿⣿⡏⡏⣿⣿⣿⡀⡀
⠐⡢⡤⢼⣿⣿⠸⠿⠛⠛⠻⣿⣿⣿⣿⣷⡿⠿⠿⢿⣶⢸⣿⣿⣿⣇⣀⣻⣿⢿⡇⡀
⡀⡀⠁⢸⢸⡛⠰⣺⣧⣠⣤⣦⣽⣿⣿⡯⠼⣤⡤⣥⣬⢸⣿⣿⣿⣻⣿⣿⣹⣹⣟⡡
⡀⡀⡀⢠⡀⡀⢀⢿⣿⣿⣿⣱⣹⣿⣿⣿⣿⣿⣿⣷⡏⢈⡿⢏⢯⣟⣫⣵⣟⣿⡆⡀
⡀⡀⡀⣸⡀⡀⡀⢿⣿⣿⢿⣿⣿⣿⣿⣿⠿⢿⣿⣿⣴⢈⡕⠁⡀⣩⣴⣾⣿⣿⡇⡀
⡀⡀⢀⡇⢀⡀⡀⡈⠻⣿⣷⣿⣭⣿⣭⣽⣿⣿⣿⣿⡿⠋⡀⡀⢠⣿⣿⣿⣿⣿⡇⡀
⡀⡀⣼⠇⣷⣿⡄⠆⡀⠈⠛⢿⣿⣿⣿⣿⣿⠿⣟⣯⡀⡀⡀⡀⣰⣿⣿⣿⣿⣿⣿⡀
⡀⢰⣿⡇⣿⣿⣟⠘⠂⠄⡀⡀⠉⣭⣭⣽⣾⣿⣿⣿⡀⡀⡀⢼⣿⣿⣿⣿⣿⣿⡏⡇]],
}

math.randomseed(vim.uv.hrtime())
local frieren_header = frieren_headers[math.random(#frieren_headers)]

require('todo-comments').setup()
require('edgy').setup {}
Snacks.setup {
  picker = {
    ui_select = true,
    win = {
      input = {
        keys = {
          ['<Esc>'] = { 'close', mode = { 'i', 'n' } },
          ['<C-c>'] = { 'close', mode = { 'i', 'n' } },
        },
      },
    },
  },
  terminal = {
    shell = 'fish',
  },
  dashboard = { enabled = false },
}

-- stylua: ignore start

map('n', '<leader>fr', function() Snacks.picker.recent() end, { desc = 'Recent files' })
map('n', '<C-n>', function() Snacks.picker.buffers { current = false } end, { desc = 'Buffers' })
map('n', '<leader>fm', function() Snacks.picker.man() end, { desc = 'Man Pages' })
map('n', '<leader>fh', function() Snacks.picker.help() end, { desc = 'Helps' })
map('n', '<leader>fp', function() Snacks.picker() end, { desc = 'Pickers' })

map('n', '<C-s>', function() Snacks.picker.lines() end, { desc = 'Lines' })

map('n', '<leader>fd', function() Snacks.picker.diagnostics_buffer() end, { desc = 'Diagnostics buffer' })
map('n', '<leader>fD', function() Snacks.picker.diagnostics() end, { desc = 'Diagnostics' })

map('n', '<leader>ss', function() Snacks.picker.lsp_symbols { layout = { preset = 'vscode', preview = 'main' } } end, { desc = 'LSP Symbols' })
map('n', '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, { desc = 'LSP Workspace Symbols' })

map('n', '<leader>fc', function()
  Snacks.picker.colorschemes {
    finder = function()
      return vim.tbl_filter(function(item)
        return not vim.startswith(item.file, vim.env.VIMRUNTIME .. '/colors/')
      end, require('snacks.picker.source.vim').colorschemes())
    end,
  }
end, { desc = 'Colorschemes' })

map('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'Lazygit' })

map('n', '<leader>gf', function() Snacks.lazygit.log_file() end, { desc = 'Lazygit log file' })

map('n', '<leader>gbl', function() Snacks.git.blame_line() end, { desc = 'Git Blame Line' })

map('n', '<leader>d', function() Snacks.bufdelete() end, { desc = 'Hide buffer' })
map('n', '<leader>D', function() Snacks.bufdelete { wipe = true } end, { desc = 'Hide buffer' })

map('n', '<leader>bo', function() Snacks.bufdelete.other() end, { desc = 'Close other buffers' })

map('n', '<leader>ft', function() Snacks.picker.todo_comments { keywords = { 'TODO', 'FIX', 'FIXME' } } end, { desc = 'Todo/Fix/Fixme' })

map('n', '<leader>fz', function() Snacks.picker.quickfix() end, { desc = 'Quickfix' })
map('n', '<leader>fL', function() Snacks.picker.loclist() end, { desc = 'Location list' })

map('n', '<leader>.', function() Snacks.scratch { ft = 'markdown' } end, { desc = 'Toggle Scratch Buffer' })
map('n', '<leader>S', function() Snacks.scratch.select() end, { desc = 'Select Scratch Buffer' })

-- stylua: ignore end
