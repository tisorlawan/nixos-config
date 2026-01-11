-- ¦, ┆ or │ to d
return {
  "saghen/blink.indent",
  --- @module 'blink.indent'
  --- @type blink.indent.Config
  opts = {
    mappings = {
      -- which lines around the scope are included for 'ai': 'top', 'bottom', 'both', or 'none'
      border = "both",
      -- set to '' to disable
      -- textobjects (e.g. `y2ii` to yank current and outer scope)
      object_scope = "ii",
      object_scope_with_border = "ai",
      -- motions
      goto_top = "[i",
      goto_bottom = "]i",
    },
    scope = {
      enabled = true,
      char = "│",
    },
    static = {
      enabled = false,
      char = "│",
      whitespace_char = nil, -- inherits from `vim.opt.listchars:get().space` when `nil` (see `:h listchars`)
      priority = 1,
      -- specify multiple highlights here for rainbow-style indent guides
      -- highlights = { 'BlinkIndentRed', 'BlinkIndentOrange', 'BlinkIndentYellow', 'BlinkIndentGreen', 'BlinkIndentViolet', 'BlinkIndentCyan' },
      highlights = { "BlinkIndent" },
    },
    scope = {
      enabled = true,
    },
  },
}
