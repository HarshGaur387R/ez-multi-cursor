-- Cursor movement module for ez-multi-cursor
local Utils = require("ez-multi-cursor.utils")
local Rendering = require("ez-multi-cursor.rendering")
local NAMESPACE = Rendering.namespace

local M = {}

--- Recursive function to move horizontally all the extramarks on a row
---@param cursor vim.api.keyset.get_extmark
---@param x integer
local function recursively_move_cursor_horizontally(cursor, x)
	local buffer = vim.api.nvim_get_current_buf()

	-- 	print("In Recursion")
	local id = cursor[1]
	local row = cursor[2]
	local col = cursor[3]
	local current_line = Utils.get_line(row, buffer)

	if (col + x >= #current_line) or (col + x < 0) then
		return;
	end

	local mark = Utils.is_there_already_an_extramark(row, col + x, buffer, NAMESPACE)

	if mark.exist == true then
		local next_cursor = vim.api.nvim_buf_get_extmark_by_id(buffer, NAMESPACE, mark.id, { details = true })
		recursively_move_cursor_horizontally({ mark.id, next_cursor[1], next_cursor[2], next_cursor[3] }, x)
	end


	Rendering.add_highlight(row, col + x, buffer)
	Rendering.remove_highlight(id, buffer)
end


--- Sets x coordinate to all the cursors
---@param x integer
function M.set_x_cordinate(x)
	local buffer = vim.api.nvim_get_current_buf();
	local namespace = Rendering.namespace;

	---@type vim.api.keyset.get_extmark
	local cursors = vim.api.nvim_buf_get_extmarks(buffer, namespace, 0, -1, { details = true })

	-- Sort cursors by column based on movement direction
	-- Moving right: process rightmost first (DESC) to avoid reprocessing
	-- Moving left: process leftmost first (ASC) to avoid reprocessing
	if x > 0 then
		table.sort(cursors, function(a, b) return a[3] > b[3] end)
	else
		table.sort(cursors, function(a, b) return a[3] < b[3] end)
	end

	for _, cursor in ipairs(cursors) do
		local cursor_row = cursor[2]
		local cursor_col = cursor[3]
		local current_line = Utils.get_line(cursor_row, buffer)


		-- Check if new position exceeds line length
		if (cursor_col + x >= #current_line) and (x > 0) then
			-- Check if last character is already a space
			local last_char = current_line:sub(-1)
			if last_char ~= " " then
				-- Add a space at the end
				Utils.append_whitespace(buffer, cursor_row)
			end
		end

		recursively_move_cursor_horizontally(cursor, x)
	end
end

--- Recursive function to move vertically all the extramarks on a column
---@param cursor vim.api.keyset.get_extmark
---@param y integer
local function recursively_move_cursor_vertically(cursor, y)
	local buffer = vim.api.nvim_get_current_buf()
	local total_lines = vim.api.nvim_buf_line_count(buffer)

	local id = cursor[1]
	local row = cursor[2]
	local col = cursor[3]

	if (row + y >= total_lines) or (row + y < 0) then
		return
	end

	local nextLine = Utils.get_line(row + y, buffer)

	if #nextLine == 0 and total_lines > row then
		nextLine = Utils.replace_line(row + y, " ", buffer)
	end

	-- Adjust column if target line is shorter
	local target_col = col
	if #nextLine > 0 and #nextLine <= col then
		target_col = #nextLine - 1
	end

	local mark = Utils.is_there_already_an_extramark(row + y, target_col, buffer, NAMESPACE)

	if mark.exist == true then
		local next_cursor = vim.api.nvim_buf_get_extmark_by_id(buffer, NAMESPACE, mark.id, { details = true })
		recursively_move_cursor_vertically({ mark.id, next_cursor[1], next_cursor[2], next_cursor[3] }, y)
	end

	-- After recursively clearing the path, move this cursor to its target position
	Rendering.add_highlight(row + y, target_col, buffer)
	Rendering.remove_highlight(id, buffer)
end

--- Sets y coordinate to all the cursors
---@param y integer
function M.set_y_cordinate(y)
	local buffer = vim.api.nvim_get_current_buf()
	local namespace = Rendering.namespace;

	---@type vim.api.keyset.get_extmark
	local cursors = vim.api.nvim_buf_get_extmarks(buffer, namespace, 0, -1, { details = true })

	-- Sort cursors by row based on movement direction
	-- Moving down: process bottommost first (DESC) to avoid reprocessing
	-- Moving up: process topmost first (ASC) to avoid reprocessing
	if y > 0 then
		table.sort(cursors, function(a, b) return a[2] > b[2] end)
	else
		table.sort(cursors, function(a, b) return a[2] < b[2] end)
	end

	for _, cursor in ipairs(cursors) do
		recursively_move_cursor_vertically(cursor, y)
	end
end

return M
