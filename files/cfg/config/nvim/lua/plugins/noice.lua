return {
  "folke/noice.nvim",
  event = "VeryLazy",
  -- enabled = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  -- stylua: ignore
  keys = {
    { "<leader>sn", "", desc = "+noice" },
    { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline", },
    { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message", },
    { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History", },
    { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All", },
    { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All", },
    { "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)", },
    { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = { "i", "n", "s" }, },
    { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = { "i", "n", "s" }, },
  },
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      progress = { enabled = false },
      signature = { enabled = false },
    },

    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = false,
      command_palette = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
    routes = {
      {
        view = "split",
        filter = { event = "msg_show", min_height = 20 },
      },
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+ lines yanked" },
            { find = "%d+ more lines" },
            { find = "%d+ fewer lines" },
            { find = "valid diagnostics" },
            { find = "-disabled-" },
            { find = "-enabled-" },
            { find = "Already at newest change" },
            { find = "no targets" },
            { find = "No hunks" },
            { find = "E16: Invalid range" },
            { find = "E23: No alternate file" },
            { find = "E486: Pattern not found" },
            { find = "E21: Cannot make changes" },
            { find = "E354: Invalid register name" },
            { find = "E553: No more items" },
            { find = "E349: No identifier under" },
            { find = "lines <ed" },
            { find = "lines >ed" },
            { find = "Hunk %d+ of %d+" },
            { find = "%d+ lines indented" },
            { find = "The only match" },
            { find = "match %d+ of %d+" },
            { find = "E73: Tag stack empty" },
          },
        },
        view = "mini",
      },
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B written" },
            { find = "arglist: %d+ files" },
            { find = "lines indented" },
            { find = "%d+ lines moved" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
            { find = "E490: No fold found" },
            { find = "not found:" },
            { find = "%d+ lines to indent" },
          },
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "^\\V" },
            { find = "^\\<" },
            { find = "^/" },
          },
          error = true,
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = "notify",
          any = {
            { find = "Renamed" },
            { find = "no manual entry" },
            { find = "No more references" },
            { find = "LSP: no handler for" },
            { find = "Toggling hidden files" },
            { find = "No results found for `lsp_definitions`" },
          },
        },
        view = "mini",
      },
      {
        filter = {
          event = "notify",
          any = {
            { find = "No results for" },
            { find = "No information available" },
            { find = "Renamed" },
            { find = "-32802" },
            { find = "No results found for `buffers`" },
          },
        },
        opts = { skip = true },
      },
    },
  },
  config = function(_, opts)
    if vim.o.filetype == "lazy" then
      vim.cmd([[messages clear]])
    end
    require("noice").setup(opts)
  end,
}
