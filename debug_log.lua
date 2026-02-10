--- debug_log function write log in debug-log.text file
---@param msg string
function Debug_log(msg)
	-- Build the path to the log file

	local log_path = debug.getinfo(1, "S").source:sub(2) -- path to init.lua
	log_path = vim.fn.fnamemodify(log_path, ":h") .. "/debug-log.text"

	-- Open the file in append mode
	local file = io.open(log_path, "a")
	if not file then
		vim.notify("Failed to open debug log file: " .. log_path, vim.log.levels.ERROR)
		return
	end

	-- Write timestamp + message
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	file:write(string.format("[%s] %s\n", timestamp, msg))

	-- Close the file
	file:close()
end

return Debug_log
