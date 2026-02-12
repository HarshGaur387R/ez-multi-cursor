--ez-multi-cursor
local M = {}
local Cursor = require("Cursor")
local Debug_log = require("debug_log")

-- Storing multiple cursors positions
M.cursors = {}
M.namespace = vim.api.nvim_create_namespace("ez-multi-cursor")
M.enabled = false


-- Configuration
M.config = {
	highlight_group = 'Visual',
	insert_mode_keys = true,
}

--- Finds the index of cursor in cursors table by its key field
---@param key string
local function findIndex(key)
	local index = -1

	for i = 1, #M.cursors, 1 do
		if M.cursors[i].key == key then
			index = i
			break;
		end
	end

	return index
end


--- Removes the curors from cursors by given given
---@param index integer
local function remove_cursor_from_cursors(index)
	table.remove(M.cursors, index)
end


--- Adds a new cursor to cursors table
---@param cur Cursor
local function add_new_cursor_in_cursors(cur)
	local cursor = Cursor.new(cur.x_cordinate, cur.y_cordinate, cur.buf, nil, cur.key)
	table.insert(M.cursors, cursor)
end

---Adds a cursor in cursor table if cursor doesn't exist, otherwise removes it
local function add_or_remove_cursor()
	local buf = vim.api.nvim_get_current_buf()
	local current_window = vim.api.nvim_get_current_win()
	local pos = vim.api.nvim_win_get_cursor(current_window)
	local row, col = pos[1], pos[2]
	local current_line = vim.api.nvim_get_current_line()

	-- Early return for empty lines
	if #current_line == 0 then
		current_line = Replace_line(row, " ", buf)
		col = 0
	end

	-- Early return so it col_end wont exceed
	if col == #current_line then return end

	-- Remove Cursor if its already exist
	local key = row .. ":" .. col
	local index = findIndex(key)

	-- If index is smaller than 0, then add new cursor to cursors table.
	if index < 0 then
		add_new_cursor_in_cursors(
			{
				x_cordinate = col,
				y_cordinate = row,
				key = key,
				buf = buf
			}
		)
	else
		remove_cursor_from_cursors(index)
	end

	Un_render_cursors();
	Render_cursors();
	M.enabled = true;
end


--- Render_cursors render all the cursor on nvim window
function Render_cursors()
	for i = 1, #M.cursors, 1 do
		local c = M.cursors[i]
		local id = Add_Highlight(c.y_cordinate - 1, c.x_cordinate, c.buf)
		M.cursors[i].cursorId = id
	end
end

-- This function un-render all the cursors from nvim window
function Un_render_cursors()
	local current_buf = vim.api.nvim_get_current_buf();
	vim.api.nvim_buf_clear_namespace(current_buf, M.namespace, 0, -1)
	for i = 1, #M.cursors, 1 do
		if M.cursors[i].cursorId then
			Remove_Highlight(M.cursors[i].cursorId, M.cursors[i].buf)
			M.cursors[i].cursorId = nil
		end
	end
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
		cursorId = vim.api.nvim_buf_set_extmark(buf, M.namespace, row, col, {
			end_row = row,
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

---Replace a specific line in the current buffer.
---@param line_number integer  -- 1-based line number
---@param new_text string      -- replacement text
---@return string -- Newely created line
function Replace_line(line_number, new_text, bufnr)
	local start = line_number - 1
	local finish = line_number

	-- Replace the line
	vim.api.nvim_buf_set_lines(bufnr, start, finish, false, { new_text })
	local lines = vim.api.nvim_buf_get_lines(bufnr, start, finish, false)

	return lines[1]
end

--- sets x cordinate to all the cursors
--- @param x integer
function Set_X_Cordinate(x)
	local buffer = vim.api.nvim_get_current_buf();

	for i = 1, #M.cursors, 1 do
		local cursor = M.cursors[i]
		local current_line = Get_line(cursor.y_cordinate, buffer)

		if buffer == cursor.buf then
			if (#current_line > cursor.x_cordinate + x) and (cursor.x_cordinate + x >= 0) then
				cursor.x_cordinate = cursor.x_cordinate + x
				local newKey = cursor.y_cordinate .. ":" .. cursor.x_cordinate
				cursor.key = newKey
				M.cursors[i] = cursor
			end
		end
	end

	Un_render_cursors();
	Render_cursors();
end

--- Sets y cordinate to all the cursors
--- @param y integer
function Set_Y_Cordinate(y)
	local buffer = vim.api.nvim_get_current_buf()
	local total_lines = vim.api.nvim_buf_line_count(buffer)

	for i = 1, #M.cursors, 1 do
		local cursor = M.cursors[i]

		if (total_lines >= cursor.y_cordinate + y) and (cursor.y_cordinate + y > 0) then
			local nextLine = Get_line(cursor.y_cordinate + y, buffer)

			if #nextLine == 0 then
				nextLine = Replace_line(cursor.y_cordinate + y, " ", buffer)
			end

			if #nextLine > 0 and #nextLine <= cursor.x_cordinate then
				cursor.x_cordinate = #nextLine - 1
			end

			cursor.y_cordinate = cursor.y_cordinate + y
			local newKey = cursor.y_cordinate .. ":" .. cursor.x_cordinate
			cursor.key = newKey
			M.cursors[i] = cursor
		end
	end

	Un_render_cursors()
	Render_cursors()
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

	vim.keymap.set('n', '<C-d>', add_or_remove_cursor, { desc = "Adds a psuedo cursor at current cursor" })
	vim.keymap.set('n', '<Esc>', function()
		local buf = vim.api.nvim_get_current_buf();
		Remove_All_Highlights(buf, M.namespace)
		return "<Esc>"
	end, { expr = true })

	vim.keymap.set("n", "<A-Right>", function()
		vim.schedule(function()
			Set_X_Cordinate(1)
		end)
		return ""
	end, { desc = "Move to right" })

	vim.keymap.set("n", "<A-Left>", function()
		vim.schedule(function()
			Set_X_Cordinate(-1)
		end)
		return ""
	end, { desc = "Move to left" })

	vim.keymap.set("n", "<A-Up>", function()
		vim.schedule(function()
			Set_Y_Cordinate(-1)
		end)
		return ""
	end, { desc = "Move to up" })

	vim.keymap.set("n", "<A-Down>", function()
		vim.schedule(function()
			Set_Y_Cordinate(1)
		end)
		return ""
	end, { desc = "Move to down" })


	vim.api.nvim_create_autocmd("ModeChanged", {
		pattern = "*:i", -- match any mode -> insert mode
		callback = function()
			local buf = vim.api.nvim_get_current_buf();
			Remove_All_Highlights(buf, M.namespace)
		end,
	})
end

return M
