-- Rendering and highlighting module for ez-multi-cursor
local Utils = require("ez-multi-cursor.utils")
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

	for i = 1, n, 1 do

	end
end

return M
