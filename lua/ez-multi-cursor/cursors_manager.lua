-- Cursor collection manager for ez-multi-cursor
local Rendering = require("ez-multi-cursor.rendering")
local Utils = require("ez-multi-cursor.utils")
local NAMESPACE = Rendering.namespace

local M = {}

-- Storing multiple cursors positions
M.cursors = {}

function M.add_or_remove_cursor()
	local buf = vim.api.nvim_get_current_buf()
	local current_window = vim.api.nvim_get_current_win()
	local row, col = Utils.get_cursor_position(current_window)
	local current_line = Utils.get_line(row - 1, buf)
	local total_line = vim.api.nvim_buf_line_count(buf)

	-- Safetu check
	if row > total_line or col < 0 then return end

	local mark = Utils.is_there_already_an_extramark(row - 1, col, buf, NAMESPACE)

	if mark.exist then
		vim.api.nvim_buf_del_extmark(buf, NAMESPACE, mark.id)
		return
	end

	if #current_line == 0 then
		current_line = Utils.replace_line(row - 1, " ", buf)
		col = 0
	end

	vim.api.nvim_buf_set_extmark(buf, NAMESPACE, row - 1, col, {
		end_row = row - 1,
		end_col = col + 1,
		hl_group = "Cursor"
	})
end

--- Clear all cursors
function M.clear_all_cursors()
	M.cursors = {}
end

return M
