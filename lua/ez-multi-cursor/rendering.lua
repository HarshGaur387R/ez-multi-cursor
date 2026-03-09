-- Rendering and highlighting module for ez-multi-cursor
local Utils = require("ez-multi-cursor.utils")
local TextInsertion = require("ez-multi-cursor.text_insertion_state")
local M = {}

M.namespace = vim.api.nvim_create_namespace("ez-multi-cursor")

--- Add_Highlight function shows a vertical cursor bar using virtual text
---@param row integer
---@param col integer
---@param buf integer
---@return integer | nil
function M.add_highlight(row, col, buf)
	local current_buff = vim.api.nvim_get_current_buf();
	local cursorId = nil
	if buf == current_buff then
		cursorId = vim.api.nvim_buf_set_extmark(buf, M.namespace, row, col, {
			end_row = row,
			end_col = col + 1,
			hl_group = "Cursor",
		})
		TextInsertion.setState(true)
	end
	return cursorId
end

--- Remove_Highlight function delete extmark on the current buffer.
---@param cursorId integer
---@param buf integer
function M.remove_highlight(cursorId, buf)
	local current_buff = vim.api.nvim_get_current_buf()
	if buf == current_buff then
		vim.api.nvim_buf_del_extmark(buf, M.namespace, cursorId)
	end
end

function M.overwrite_highlight(row, col, buf)
	local current_buff = vim.api.nvim_get_current_buf();
	local cursorId = nil
	if buf == current_buff then
		local mark = Utils.is_there_already_an_extramark(row, col, current_buff, M.namespace)

		if mark.exist == true then M.remove_highlight(mark.id, buf) end

		cursorId = vim.api.nvim_buf_set_extmark(buf, M.namespace, row, col, {
			end_row = row,
			end_col = col + 1,
			hl_group = "Cursor",
		})
		TextInsertion.setState(true)
	end
	return cursorId
end

--- Remove_All_Highlights: Remove all highlights at once
---@param buf integer
function M.remove_all_highlights(buf)
	vim.api.nvim_buf_clear_namespace(buf, M.namespace, 0, -1)
end

--- GetPositionOfExtMarks: This function returns [row, col] of extmark
---@param id integer
---@param buffer integer
---@return table
function M.get_position_of_extmarks(id, buffer)
	local position = vim.api.nvim_buf_get_extmark_by_id(buffer, M.namespace, id, {})
	return position
end

--- Setup highlight color for cursor bar
function M.setup_highlights()
	if vim.fn.hlID("CursorBar") == 0 then
		vim.api.nvim_set_hl(0, "CursorBar", { fg = "Yellow", bg = "NONE" })
	end
end

--- Add n number cursors vertically
--- @param n integer
--- @param y integer
function M.add_n_cursors_vertically(n, y)
	local buf = vim.api.nvim_get_current_buf()
	local current_window = vim.api.nvim_get_current_win()
	local row, col = Utils.get_cursor_position(current_window)
	local total_line = vim.api.nvim_buf_line_count(buf)

	for i = 0, n - 1, 1 do
		local target_row = row + (i * y)

		-- Boundary check
		if target_row >= 1 and target_row <= total_line then
			local current_line = Utils.get_line(target_row - 1, buf)
			local line_length = #current_line

			-- Handle empty lines
			if line_length == 0 then
				Utils.replace_line(target_row - 1, " ", buf)
				line_length = 1
			end

			-- Adjust column if line is shorter than current column
			local target_col = col
			if col >= line_length then
				target_col = line_length - 1
			end

			-- Skip if there's already an extmark at this position
			local existing_mark = Utils.is_there_already_an_extramark(target_row - 1, target_col, buf,
				M.namespace)
			if existing_mark.exist then
				goto continue
			end

			M.add_highlight(target_row - 1, target_col, buf)

			::continue::
		end
	end
end

return M
