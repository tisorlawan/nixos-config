return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      icons_enabled = false,
      theme = "auto",
      disabled_filetypes = {},
      always_divide_middle = true,
      section_separators = { left = "", right = "" },
      component_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = {
        {
          "mode",
          fmt = function(str)
            return str:sub(1, 1)
          end,
        },
      },
      lualine_b = {
        "branch",
        -- "diff",
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = {
            error = "󰅚 ",
            warn = "󰀪 ",
            hint = "󰌶 ",
            info = " ",
          },
          colored = true,
        },
      },
      lualine_c = {
        {
          "filename",
          path = 1,
        },
      },
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },

      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    extensions = {},
  },
  event = "VimEnter",
}
