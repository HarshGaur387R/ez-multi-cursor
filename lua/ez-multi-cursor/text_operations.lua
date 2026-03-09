-- Text operations module for ez-multi-cursor
local Rendering = require("ez-multi-cursor.rendering")
local Utils = require("ez-multi-cursor.utils")

local M = {}

--- InsertText function insert text at the given cursors positions
---@param str string
function M.insert_text(str)
	local buffer = vim.api.nvim_get_current_buf();
	local namespace = Rendering.namespace;

	---@type vim.api.keyset.get_extmark
	local cursors = vim.api.nvim_buf_get_extmarks(buffer, namespace, 0, -1, { details = true })

	for i = 1, #cursors do
		local cursor = cursors[i]
		local position = Rendering.get_position_of_extmarks(cursor[1], buffer)
		local row, col = position[1], position[2]

		-- Replace text at [row, col] with inserted string
		vim.api.nvim_buf_set_text(
			buffer,
			row, col, -- start position
			row, col, -- end position (same col → pure insertion)
			{ str } -- replacement text
		)
	end
end

function M.remove_character()
	local buffer = vim.api.nvim_get_current_buf()
	local namespace = Rendering.namespace

	-- Collect all extmarks in the buffer at once
	local marks = vim.api.nvim_buf_get_extmarks(
		buffer,
		namespace,
		0, -1, -- full buffer range
		{ details = true }
	)

	-- Group marks by line
	local marks_by_line = {}
	for _, mark in ipairs(marks) do
		local id            = mark[1]
		local line          = mark[2]
		local col           = mark[3]
		marks_by_line[line] = marks_by_line[line] or {}
		table.insert(marks_by_line[line], { id = id, col = col })
	end

	-- Process each line independently
	for line, mark_list in pairs(marks_by_line) do
		-- Sort LEFT-TO-RIGHT so we can track cumulative column shift cleanly.
		-- Each deletion of (col - 1) shifts the buffer left by 1 for every
		-- column that comes AFTER it. Processing left-to-right means each
		-- mark's original col is unaffected by previous deletions (they were
		-- all to its left and already accounted for via `offset`).
		table.sort(mark_list, function(a, b) return a.col < b.col end)

		-- `offset` = total characters deleted so far on this line.
		-- Every original col must be reduced by `offset` to get the real
		-- current col in the (already mutated) buffer.
		local offset = 0

		for _, mark_info in ipairs(mark_list) do
			local original_col = mark_info.col
			local id           = mark_info.id

			-- Translate original col → current col in the live buffer
			local current_col  = original_col - offset

			-- Always remove the old extmark first (we will re-place it or not)
			Rendering.remove_highlight(id, buffer)

			if current_col > 0 then
				-- Delete the character immediately before the cursor.
				-- current_col is guaranteed valid because:
				--   - We sorted left-to-right.
				--   - `offset` exactly accounts for every character removed
				--     to the left of this mark so far.
				vim.api.nvim_buf_set_text(
					buffer,
					line, current_col - 1,
					line, current_col,
					{ "" }
				)
				offset = offset + 1

				-- New position is one to the left of where the cursor was.
				local new_col = current_col - 1

				-- Re-place the mark only if the position is still inside the line.
				local line_content = Utils.get_line(line, buffer)
				if new_col < #line_content then
					Rendering.add_highlight(line, new_col, buffer)
				end
				-- If new_col is beyond the line length the mark is simply dropped.
			else
				-- Cursor is at column 0 — nothing to delete, nowhere to move.
				-- Re-place the mark exactly where it was so it is not lost.
				local line_content = Utils.get_line(line, buffer)
				if current_col < #line_content then
					Rendering.add_highlight(line, current_col, buffer)
				end
			end
		end
	end
end

return M
