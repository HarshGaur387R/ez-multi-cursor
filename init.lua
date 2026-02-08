--ez-multi-cursor
local M = {}

-- Storing multiple cursors positions
M.cursors = {}
M.namespace = vim.api.nvim_create_namespace("ez-multi-cursor")
M.enabled = false

-- Configuration
M.config = {
	highlight_group = 'Visual',
	insert_mode_keys = true,
}

-- Debug log function to log messages in a file.
local function debug_log(msg)
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


---Adds a cursor in cursor table if cursor doesn't exist, otherwise removes it
local function add_or_remove_cursor()
	local buf = vim.api.nvim_get_current_buf()
	local current_window = vim.api.nvim_get_current_win()
	local pos = vim.api.nvim_win_get_cursor(current_window)
	local row, col = pos[1], pos[2]
	local current_line = vim.api.nvim_get_current_line()

	-- Early return for empty lines
	if #current_line == 0 then return end
	if col == #current_line then return end

	-- Remove Cursor if its already exist
	local key = row .. ":" .. col
	local cursor = M.cursors[key]

	if not cursor then
		local cursorId = Add_Highlight(row, col, buf)
		M.cursors[key] = { buf = buf, row = row, col = col, cursorId = cursorId }
	else
		Remove_Highlight(cursor.cursorId, buf)
		M.cursors[key] = nil;
	end

	M.enabled = true;
end

---Add_Highlight function show create extmark on the current buffer and return cursorId.
---@param row integer
---@param col integer
---@param buf integer
---@return integer
function Add_Highlight(row, col, buf)
	local current_buff = vim.api.nvim_get_current_buf();
	local cursorId = 0
	if buf == current_buff then
		cursorId = vim.api.nvim_buf_set_extmark(buf, M.namespace, row - 1, col, {
			end_row = row - 1,
			end_col = col + 1,
			hl_group = "Cursor"
		})
	end

	return cursorId
end

--- Remove_Highlight function delete extmark on the current buffer.
---@param cursorId integer
---@param buf integer
function Remove_Highlight(cursorId, buf)
	local current_buff = vim.api.nvim_get_current_buf();
	if buf == current_buff then
		vim.api.nvim_buf_del_extmark(buf, M.namespace, cursorId)
	end
end

--- Remove all highlights at once
--- @param buf integer
--- @param ns integer
function Remove_All_Highlights(buf, ns)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	M.cursors = {}
end

--- This function move all the cursors
---@param x integer
---@param y integer
function Move_cursors(x, y)
	local current_buf = vim.api.nvim_get_current_buf();

	-- Collect all keys first to avoid iterating over newly added entries
	local keys_to_process = {}
	for key, _ in pairs(M.cursors) do
		table.insert(keys_to_process, key)
	end

	for _, key in ipairs(keys_to_process) do
		local cursor = M.cursors[key]
		if cursor == nil then
			goto continue
		end

		local current_line = Get_line(cursor.row, current_buf)

		if current_buf == cursor.buf then
			if #current_line > (cursor.col + x) and (cursor.col + x) >= 0 then
				local updated_cursor = {
					buf = cursor.buf,
					row = cursor.row,
					col = cursor.col + x,
					cursorId = cursor.cursorId
				}

				local newKey = updated_cursor.row .. ":" .. updated_cursor.col

				if M.cursors[newKey] then
					Remove_Highlight(
						M.cursors[newKey].cursorId,
						M.cursors[newKey].buf
					)
				end

				Remove_Highlight(cursor.cursorId, cursor.buf)
				updated_cursor.cursorId = Add_Highlight(
					updated_cursor.row,
					updated_cursor.col,
					updated_cursor.buf
				)

				debug_log(
					key .. "={row:" ..
					cursor.row ..
					", col:" ..
					cursor.col ..
					", cursorId:" ..
					cursor.cursorId .. "}, VS " ..
					newKey .. "={row:" ..
					updated_cursor.row ..
					", col:" ..
					updated_cursor.col ..
					", cursorId:" ..
					updated_cursor.cursorId .. "}"
				)

				M.cursors[key] = nil
				M.cursors[newKey] = updated_cursor
			end
		end

		::continue::
	end
end

--- get_line function returns a line indexed at line_number
---@param line_number any
---@param buf any
---@return string
function Get_line(line_number, buf)
	local start = line_number - 1;
	local finish = line_number
	local lines = vim.api.nvim_buf_get_lines(buf, start, finish, false)

	return lines[1]
end

--- Configure the plugin
---@param opts table
function M.setup(opts)
	opts = opts or {}

	vim.keymap.set('i', '<C-d>', add_or_remove_cursor, { desc = "Adds a psuedo cursor at current cursor" })
	vim.keymap.set('i', '<Esc>', function()
		local buf = vim.api.nvim_get_current_buf();
		Remove_All_Highlights(buf, M.namespace)
		return "<Esc>"
	end, { expr = true })
	vim.keymap.set("i", "<A-Right>", function()
		vim.schedule(function()
			Move_cursors(1, 0)
		end)
		-- Return nothing special; just consume the key
		return ""
	end, { desc = "Move to right ->" })
	vim.keymap.set("i", "<A-Left>", function()
		vim.schedule(function()
			Move_cursors(-1, 0)
		end)
		-- Return nothing special; just consume the key
		return ""
	end, { desc = "Move to right ->" })
end

return M
