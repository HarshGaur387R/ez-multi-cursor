--- debug_log function writes log to debug-log.text file
---@param msg string
function Debug_log(msg)
	-- Resolve plugin directory (parent of this file)
	local script_path = debug.getinfo(1, "S").source:sub(2)
	local plugin_dir = vim.fn.fnamemodify(script_path, ":h")
	local log_path = plugin_dir .. "/debug-log.text"

	-- Ensure plugin directory exists
	if vim.fn.isdirectory(plugin_dir) == 0 then
		vim.fn.mkdir(plugin_dir, "p")
	end

	-- Open the file in append mode (creates if doesn't exist)
	local file, err = io.open(log_path, "a")
	if not file then
		vim.notify("Failed to open debug log file: " .. log_path .. " (" .. tostring(err) .. ")",
			vim.log.levels.ERROR)
		return
	end

	-- Write timestamp + message
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	file:write(string.format("[%s] %s\n", timestamp, msg))

	-- Close the file
	file:close()
end

return Debug_log
