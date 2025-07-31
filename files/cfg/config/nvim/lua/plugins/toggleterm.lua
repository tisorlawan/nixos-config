return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    local Terminal = require("toggleterm.terminal").Terminal

    -- Create a constructor with our custom methods
    local CustomTerminal = Terminal:new({
      gf = function(self)
        -- Get the entire word under cursor including the file:line:col format
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]

        -- Extract the pattern from the line, being more lenient with spaces
        local pattern
        for p in line:gmatch("%s*%-%-%>%s*([^%s][^:]-:%d+:?%d*)") do
          pattern = p
        end

        if not pattern then
          -- Try without arrow
          for p in line:gmatch("([^%s][^:]-:%d+:?%d*)") do
            pattern = p
          end
        end

        if not pattern then
          vim.notify("No file:line:col pattern found", vim.log.levels.WARN)
          return
        end

        -- Parse file, line, and column from the pattern
        local file, line_num, col_num = pattern:match("([^:]+):(%d+):(%d+)")
        if not file then
          file, line_num = pattern:match("([^:]+):(%d+)")
          col_num = "1"
        end

        -- Find the file
        local f = vim.fn.findfile(file, "**")
        if f == "" then
          vim.notify("No file found: " .. file, vim.log.levels.WARN)
          return
        end

        -- Find the largest window
        local max_area = 0
        local largest_win = nil

        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local win_config = vim.api.nvim_win_get_config(win)
          -- Skip floating windows
          if win_config.relative == "" then
            local width = vim.api.nvim_win_get_width(win)
            local height = vim.api.nvim_win_get_height(win)
            local area = width * height
            if area > max_area then
              max_area = area
              largest_win = win
            end
          end
        end

        vim.schedule(function()
          if largest_win and vim.api.nvim_win_is_valid(largest_win) then
            -- Focus the largest window
            vim.api.nvim_set_current_win(largest_win)
            -- Open the file
            vim.cmd("e " .. f)
            -- Jump to line and column
            vim.api.nvim_win_set_cursor(0, { tonumber(line_num), tonumber(col_num) - 1 })
          else
            -- Fallback to normal buffer opening if no valid window found
            vim.cmd("e " .. f)
            vim.api.nvim_win_set_cursor(0, { tonumber(line_num), tonumber(col_num) - 1 })
          end
        end)
      end,
    })

    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 17
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.41
        end
      end,
      auto_scroll = true,
      on_create = function(term)
        term.gf = CustomTerminal.gf
      end,
      on_open = function(term)
        vim.keymap.set("n", "gf", function()
          term:gf()
        end, {
          buffer = term.bufnr,
          noremap = true,
          desc = "Go to file under cursor in largest window",
        })

        -- Flag to track first window enter
        local first_enter = true

        -- Create an autocmd to scroll to top only on first window enter
        vim.api.nvim_create_autocmd("WinEnter", {
          buffer = term.bufnr,
          callback = function()
            if first_enter then
              -- vim.cmd("normal! gg")
              first_enter = false
              return true
            end
          end,
          desc = "Scroll to top on first window enter",
        })

        -- Create an autocmd to restore search register when leaving terminal
      end,
      on_close = function(term) end,
    })

    -- Helper function to check for ./cmd and fallback to default command
    local function create_run_keymap(default_cmd, desc)
      return function()
        local cwd = vim.fn.getcwd()
        local cmd_file = cwd .. "/cmd"

        local final_cmd
        if vim.fn.executable(cmd_file) == 1 then
          final_cmd = "./cmd"
        else
          final_cmd = default_cmd
        end

        local term_cmd = string.format("TermExec cmd='%s' direction=vertical", final_cmd)
        vim.cmd(term_cmd)
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "zig",
      callback = function()
        vim.keymap.set("n", "<leader>rr", create_run_keymap("zig build run", "Run Zig project"), {
          buffer = true,
          desc = "Run Zig project or ./cmd",
        })
        vim.keymap.set("n", "t<cr>", function()
          local current_file = vim.fn.expand("%:t")
          local cmd = string.format("TermExec cmd='zig test %s' direction=vertical", current_file)
          vim.cmd(cmd)
        end, {
          buffer = true,
          desc = "Run Zig tests for current file",
        })
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "haskell",
      callback = function()
        vim.keymap.set("n", "<leader>rr", create_run_keymap("clear; cabal run --verbose=0", "Run Haskell project"), {
          buffer = true,
          desc = "Run Haskell project or ./cmd",
        })
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "rust",
      callback = function()
        vim.keymap.set("n", "<leader>rr", function()
          -- Store current window and buffer
          local current_win = vim.api.nvim_get_current_win()
          local current_buf = vim.api.nvim_get_current_buf()

          local cwd = vim.fn.getcwd()
          local cmd_file = cwd .. "/cmd"

          local final_cmd
          if vim.fn.executable(cmd_file) == 1 then
            final_cmd = "./cmd"
          else
            final_cmd = "bacon"
          end

          -- Run command in vertical split
          local term_cmd = string.format("TermExec cmd='%s' direction=vertical", final_cmd)
          vim.cmd(term_cmd)

          -- Return focus to original window
          vim.api.nvim_set_current_win(current_win)
        end, {
          buffer = true,
          desc = "Run Rust project or ./cmd",
        })
        vim.keymap.set("n", "<leader><cr>", function()
          -- Store current window and buffer
          local current_win = vim.api.nvim_get_current_win()
          local current_buf = vim.api.nvim_get_current_buf()

          -- Run bacon in vertical split
          local cmd = string.format("TermExec cmd='cargo test' direction=vertical")
          vim.cmd(cmd)

          -- Return focus to original window
          vim.api.nvim_set_current_win(current_win)
        end, {
          buffer = true,
          desc = "Run 'cargo test'",
        })
      end,
    })

    -- C filetype handler with error parsing to quickfix
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "c",
      callback = function()
        vim.keymap.set("n", "<leader>rr", function()
          local cwd = vim.fn.getcwd()
          local cmd_file = cwd .. "/cmd"

          local final_cmd
          if vim.fn.executable(cmd_file) == 1 then
            final_cmd = "./cmd"
          else
            final_cmd = "make"
          end

          -- Clear previous quickfix list
          vim.fn.setqflist({})

          -- Run in terminal only
          local term_cmd = string.format("TermExec cmd='%s' direction=vertical", final_cmd)
          vim.cmd(term_cmd)
        end, {
          buffer = true,
          desc = "Build C project or ./cmd",
        })
      end,
    })

    -- Generic handler for all other filetypes
    -- vim.api.nvim_create_autocmd("FileType", {
    --   pattern = "*",
    --   callback = function()
    --     local filetype = vim.bo.filetype
    --     -- Skip if this filetype already has a specific handler
    --     if filetype == "zig" or filetype == "haskell" or filetype == "rust" or filetype == "c" then
    --       return
    --     end
    --
    --     vim.keymap.set("n", "<leader>rr", function()
    --       local cwd = vim.fn.getcwd()
    --       local cmd_file = cwd .. "/cmd"
    --
    --       if vim.fn.executable(cmd_file) == 1 then
    --         local term_cmd = string.format("TermExec cmd='./cmd' direction=vertical")
    --         vim.cmd(term_cmd)
    --       else
    --         vim.notify("No ./cmd file found in current directory", vim.log.levels.WARN)
    --       end
    --     end, {
    --       buffer = true,
    --       desc = "Run ./cmd if it exists",
    --     })
    --   end,
    -- })
  end,
}
