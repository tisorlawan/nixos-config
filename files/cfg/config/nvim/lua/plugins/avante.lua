return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  opts = {
    -- add any opts here
    -- for example
    provider = "aihubmix",
    providers = {
      aihubmix = {
        model = "gemini-2.5-flash-preview-04-17-nothink",
      },
    },
    hints = {
      enabled = false,
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown", "Avante" },
      opts = {
        file_types = { "markdown", "Avante" },
      },
      keys = {
        {
          "<cr>",
          "<cmd>RenderMarkdown buf_toggle<CR>",
          desc = "Toggle Render Markdown for buffer",
        },
      },
      config = function(_, opts)
        require("render-markdown").setup(opts)
        local renderMarkdownGroup = vim.api.nvim_create_augroup("RenderMarkdownDefaults", { clear = true })

        vim.api.nvim_create_autocmd("FileType", {
          group = renderMarkdownGroup,
          pattern = { "markdown" },
          desc = "Disable render-markdown by default for specified filetypes",
          command = "RenderMarkdown buf_disable",
        })
      end,
    },
  },
}
