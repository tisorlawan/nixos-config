return {
  'saghen/blink.cmp',
  version = '*',
  event = { 'InsertEnter' },
  opts = function()
    local enabled_filetypes = require('config.shared').get_used_filetypes().enabled

    return {
      enabled = function()
        for _, filetype in ipairs(vim.split(vim.bo.filetype, '.', { plain = true, trimempty = true })) do
          if enabled_filetypes[filetype] then
            return true
          end
        end

        return false
      end,
      keymap = {
        preset = 'super-tab',
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<Tab>'] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            end
            return cmp.select_and_accept()
          end,
          'snippet_forward',
          'fallback',
        },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
      },
      completion = {
        list = {
          selection = {
            preselect = function()
              return not require('blink.cmp').snippet_active { direction = 1 }
            end,
            auto_insert = true,
          },
        },
        trigger = {
          show_in_snippet = false,
          prefetch_on_insert = true,
        },
        menu = {
          auto_show = function()
            return not vim.g.disable_autocomplete
          end,
          border = 'single',
          draw = {
            columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
          },
        },
        documentation = {
          auto_show = true,
          window = { min_width = 10, max_width = 100, max_height = 30, border = 'single' },
        },
        ghost_text = { enabled = false },
      },
      signature = { enabled = false },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          path = {
            opts = {
              get_cwd = function()
                return vim.fn.getcwd()
              end,
            },
          },
        },
      },
    }
  end,
}
