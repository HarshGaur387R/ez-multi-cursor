-- Utility functions for ez-multi-cursor
local M = {}

--- Get_line function returns a line indexed at line_number
---@param line_number integer
---@param buf integer
---@return string
function M.get_line(line_number, buf)
	local start = line_number
	local finish = line_number + 1
	local lines = vim.api.nvim_buf_get_lines(buf, start, finish, false)
	return lines[1] or ""
end

--- Replace_line: Replace a specific line in the current buffer.
---@param line_number integer  -- 0 Based indexing
---@param new_text string      -- replacement text
---@param bufnr integer        -- buffer number
---@return string -- Newly created line
function M.replace_line(line_number, new_text, bufnr)
	local start = line_number
	local finish = line_number + 1

	-- Replace the line
	vim.api.nvim_buf_set_lines(bufnr, start, finish, false, { new_text })
	local lines = vim.api.nvim_buf_get_lines(bufnr, start, finish, false)

	return lines[1] or ""
end

--- Returns current cursor's position (row and col)
---@param win integer
---@return integer
---@return integer
function M.get_cursor_position(win)
	local pos = vim.api.nvim_win_get_cursor(win)
	local row, col = pos[1], pos[2]

	return row, col
end

function M.is_there_already_an_extramark(target_row, target_col, buf, namespace)
	local existing_extramark = vim.api.nvim_buf_get_extmarks(buf, namespace, { target_row, target_col },
		{ target_row, target_col },
		{ details = true })

	for _, mark in ipairs(existing_extramark) do
		local id, row, col = mark[1], mark[2], mark[3]

		if (row == target_row) and (col == target_col) then
			return { exist = true, id = id }
		end
	end

	return { exist = false, id = nil }
end

--- Append a whitespace at the end of a line
---@param bufnr integer   -- buffer number (0 = current buffer)
---@param line_number integer -- 0-based line index
function M.append_whitespace(bufnr, line_number)
	-- Get the current line
	local line = vim.api.nvim_buf_get_lines(bufnr, line_number, line_number + 1, false)[1]
	if not line then return end

	-- Find the end column (length of line)
	local col = #line

	-- Insert a space at the end of the line
	vim.api.nvim_buf_set_text(bufnr, line_number, col, line_number, col, { " " })
end

return M
