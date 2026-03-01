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
---@param cursors table
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

--- Sets y coordinate to all the cursors
---@param cursors table
---@param y integer
function M.set_y_cordinate(cursors, y)
    local buffer = vim.api.nvim_get_current_buf()
    local total_lines = vim.api.nvim_buf_line_count(buffer)

    for i = 1, #cursors, 1 do
        local cursor = cursors[i]

        if (total_lines >= cursor.y_cordinate + y) and (cursor.y_cordinate + y > 0) then
            local nextLine = Utils.get_line(cursor.y_cordinate + y, buffer)

            if #nextLine == 0 then
                nextLine = Utils.replace_line(cursor.y_cordinate + y, " ", buffer)
            end

            if #nextLine > 0 and #nextLine <= cursor.x_cordinate then
                cursor.x_cordinate = #nextLine - 1
            end

            cursor.y_cordinate = cursor.y_cordinate + y
            local newKey = cursor.y_cordinate .. ":" .. cursor.x_cordinate
            cursor.key = newKey
            cursors[i] = cursor
        end
    end

    Rendering.un_render_cursors(cursors)
    Rendering.render_cursors(cursors)
end

return M
