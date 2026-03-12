return {
  'ggandor/flit.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  keys = (function()
    local keys = {}
    for _, key in ipairs { 'f', 'F', 't', 'T' } do
      table.insert(keys, { key, mode = { 'n', 'x', 'o' }, desc = key })
    end
    return keys
  end)(),
  opts = { labeled_modes = 'nx' },
}
