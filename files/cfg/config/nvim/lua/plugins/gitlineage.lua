return {
  'lionyxml/gitlineage.nvim',
  cmd = { 'GitLineage' },
  dependencies = { 'sindrets/diffview.nvim' },
  config = function()
    require('gitlineage').setup()
  end,
}
