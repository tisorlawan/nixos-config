local M = {}

local layouts = {
	{ id = "right", label = "Split right" },
	{ id = "below", label = "Split below" },
	{ id = "float", label = "Floating" },
	{ id = "full", label = "Full window" },
	{ id = "background", label = "Background (split when error)" },
}
local state_dir = vim.fn.stdpath("state") .. "/runner"
local output
local view

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = "Runner" })
end

-- Read each field on demand so separate Neovim sessions do not overwrite
-- another session's command when they change only the terminal layout.
local function read_state(name, valid)
	local path = state_dir .. "/" .. name .. ".json"
	if vim.fn.filereadable(path) == 0 then
		return nil
	end
	local ok, value = pcall(function()
		return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
	end)
	if ok and valid(value) then
		return value
	end
	notify("Invalid runner state: " .. path, vim.log.levels.WARN)
end

-- A private temporary file plus rename gives readers a complete value,
-- even when two sessions save the same field at the same time.
local function save_state(name, value)
	local temporary
	local ok, err = pcall(function()
		vim.fn.mkdir(state_dir, "p", 448)
		local fd
		fd, temporary = assert(vim.uv.fs_mkstemp(state_dir .. "/.state-XXXXXX"))
		local written, write_err = vim.uv.fs_write(fd, vim.json.encode(value), 0)
		vim.uv.fs_close(fd)
		assert(written, write_err)
		assert(vim.uv.fs_rename(temporary, state_dir .. "/" .. name .. ".json"))
	end)
	if not ok then
		if temporary then
			vim.uv.fs_unlink(temporary)
		end
		notify("Cannot save runner state: " .. tostring(err), vim.log.levels.ERROR)
	end
	return ok
end

local function last_command()
	return read_state("command", function(value)
		return type(value) == "string" and value:find("%S") ~= nil and not value:find("%z")
	end)
end

local function layout()
	return read_state("layout", function(value)
		for _, item in ipairs(layouts) do
			if item.id == value then
				return true
			end
		end
		return false
	end) or "right"
end

local function has_output()
	return output ~= nil and vim.api.nvim_buf_is_valid(output.buf)
end

local function is_running()
	return has_output() and vim.fn.jobwait({ output.job }, 0)[1] == -1
end

-- Measure the normal-window area, excluding floats, tab bars, and the cmdline.
local function split_dimensions(win, mode)
	local get_size = mode == "right" and vim.api.nvim_win_get_width or vim.api.nvim_win_get_height
	local axis = mode == "right" and 2 or 1
	local first, last = math.huge, 0
	for _, other in ipairs(vim.api.nvim_tabpage_list_wins(vim.api.nvim_win_get_tabpage(win))) do
		if vim.api.nvim_win_get_config(other).relative == "" then
			local position = vim.api.nvim_win_get_position(other)[axis]
			first = math.min(first, position)
			last = math.max(last, position + get_size(other))
		end
	end
	return get_size(win), last - first
end

local function remember_split()
	if not view or (view.layout ~= "right" and view.layout ~= "below") then
		return
	end
	if
		not vim.api.nvim_win_is_valid(view.win)
		or not has_output()
		or vim.api.nvim_win_get_buf(view.win) ~= output.buf
	then
		return
	end
	local size, extent = split_dimensions(view.win, view.layout)
	local resized = size ~= view.size and extent == view.extent
	view.size, view.extent = size, extent
	-- Ignore editor resizes and a split that expands into the last window.
	if resized and size < extent then
		save_state(view.layout .. "-ratio", size / extent)
	end
end

local function hide()
	remember_split()
	if not view or not vim.api.nvim_win_is_valid(view.win) then
		view = nil
		return
	end
	-- Do not close a window that the user has since repurposed.
	if has_output() and vim.api.nvim_win_get_buf(view.win) == output.buf then
		local last_window = view.layout ~= "float"
			and vim.api.nvim_win_call(view.win, function()
				return vim.fn.winnr("$") == 1
			end)
		if view.layout == "full" or last_window then
			local previous = view.previous
			if not vim.api.nvim_buf_is_valid(previous) then
				previous = vim.api.nvim_create_buf(true, false)
			end
			vim.api.nvim_win_set_buf(view.win, previous)
		else
			vim.api.nvim_win_close(view.win, false)
		end
	end
	view = nil
end

function M.show(mode)
	if not has_output() then
		notify("No runner output yet")
		return
	end
	if view and vim.api.nvim_win_is_valid(view.win) and vim.api.nvim_win_get_buf(view.win) == output.buf then
		vim.api.nvim_set_current_win(view.win)
	else
		mode = mode or layout()
		if mode == "background" then
			mode = "right"
		end
		local previous = vim.api.nvim_get_current_buf()
		local win
		if mode == "float" then
			local width = math.max(1, math.floor(vim.o.columns * 0.85) - 2)
			local height = math.max(1, math.floor((vim.o.lines - vim.o.cmdheight - 2) * 0.8))
			win = vim.api.nvim_open_win(output.buf, true, {
				relative = "editor",
				width = width,
				height = height,
				row = math.max(0, math.floor((vim.o.lines - height - 2) / 2)),
				col = math.max(0, math.floor((vim.o.columns - width - 2) / 2)),
				style = "minimal",
				border = "rounded",
				title = " Runner ",
				title_pos = "center",
			})
		else
			if mode == "right" then
				vim.cmd("botright vsplit")
			elseif mode == "below" then
				vim.cmd("botright split")
			end
			win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(win, output.buf)
			if mode == "right" or mode == "below" then
				local ratio = read_state(mode .. "-ratio", function(value)
					return type(value) == "number" and value > 0 and value < 1
				end) or (mode == "right" and 0.5 or 0.3)
				local _, extent = split_dimensions(win, mode)
				local set_size = mode == "right" and vim.api.nvim_win_set_width or vim.api.nvim_win_set_height
				set_size(win, math.max(1, math.floor(extent * ratio + 0.5)))
			end
		end
		view = { win = win, layout = mode, previous = previous }
		if mode == "right" or mode == "below" then
			view.size, view.extent = split_dimensions(win, mode)
		end
	end
	if is_running() then
		vim.cmd.startinsert()
	else
		vim.cmd.stopinsert()
	end
end

local function run(command, background, cwd)
	if is_running() then
		notify("A runner command is still active. Use <leader>ro to see it.", vim.log.levels.WARN)
		return
	end
	local split_on_error = not background and layout() == "background"
	local buf = vim.api.nvim_create_buf(true, true)
	vim.bo[buf].bufhidden = "hide"
	vim.b[buf].runner_command = command
	local ok, job = pcall(vim.api.nvim_buf_call, buf, function()
		return vim.fn.jobstart(command, {
			term = true,
			cwd = cwd,
			on_exit = function(_, code)
				vim.schedule(function()
					if vim.api.nvim_buf_is_valid(buf) then
						vim.b[buf].runner_exit_code = code
						if vim.api.nvim_get_current_buf() == buf then
							vim.cmd.stopinsert()
						end
					end
					if code ~= 0 and split_on_error and has_output() and output.buf == buf then
						M.show("right")
					end
					notify(
						"Command exited with code " .. code,
						code == 0 and vim.log.levels.INFO or vim.log.levels.WARN
					)
				end)
			end,
		})
	end)
	if not ok or job <= 0 then
		vim.api.nvim_buf_delete(buf, { force = true })
		notify("Cannot start command: " .. tostring(job), vim.log.levels.ERROR)
		return
	end
	local previous = output
	hide()
	output = { buf = buf, job = job }
	if previous and vim.api.nvim_buf_is_valid(previous.buf) then
		vim.api.nvim_buf_delete(previous.buf, { force = true })
	end
	vim.keymap.set("n", "q", hide, { buffer = buf, desc = "Hide runner terminal" })
	save_state("command", command)
	if background or split_on_error then
		notify("Command started without a terminal window. Use <leader>ro for output.")
	else
		M.show()
	end
end

local function prompt(default, execute, background)
	local cwd = vim.fn.getcwd()
	vim.ui.input({
		prompt = execute and "Run command: " or "Edit last command: ",
		default = default or "",
		completion = "shellcmd",
	}, function(command)
		if not command or not command:find("%S") then
			return
		end
		if execute then
			run(command, background, cwd)
		elseif save_state("command", command) then
			notify("Last command saved")
		end
	end)
end

function M.command()
	prompt(nil, true, false)
end

function M.edit()
	prompt(last_command(), false, false)
end

function M.repeat_last(background)
	local command = last_command()
	if command then
		run(command, background, vim.fn.getcwd())
	else
		prompt(nil, true, background)
	end
end

function M.select_layout()
	local current = layout()
	vim.ui.select(layouts, {
		prompt = "Runner terminal layout (next run):",
		format_item = function(item)
			return item.label .. (item.id == current and " (current)" or "")
		end,
	}, function(choice)
		if choice then
			save_state("layout", choice.id)
		end
	end)
end

function M.setup()
	vim.api.nvim_create_autocmd({ "WinResized", "BufWinLeave", "VimLeavePre" }, {
		group = vim.api.nvim_create_augroup("runner_split_ratio", { clear = true }),
		callback = remember_split,
		desc = "Remember runner split ratios",
	})
	local mappings = {
		{ "<leader>rc", M.command, "Run a new command" },
		{ "<leader>re", M.edit, "Edit last command (no execution)" },
		{
			"<leader>rr",
			function()
				M.repeat_last(false)
			end,
			"Run last command",
		},
		{
			"<leader>rb",
			function()
				M.repeat_last(true)
			end,
			"Run last command without a terminal window",
		},
		{ "<leader>ro", M.show, "Show runner output" },
		{ "<leader>rf", M.select_layout, "Select runner terminal layout" },
	}
	for _, mapping in ipairs(mappings) do
		vim.keymap.set("n", mapping[1], mapping[2], { desc = mapping[3] })
	end
end

return M
