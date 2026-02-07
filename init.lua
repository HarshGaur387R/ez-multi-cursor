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

--- Configure the plugin
--- @param opts table
function M.setup(opts)
	opts = opts or {}

	vim.keymap.set('i', '<C-d>', add_or_remove_cursor, { desc = "Adds a psuedo cursor at current cursor" })
	vim.keymap.set('i', '<Esc>', function()
		local buf = vim.api.nvim_get_current_buf();
		Remove_All_Highlights(buf, M.namespace)
		return "<Esc>"
	end, { expr = true })
	vim.keymap.set('i', '<A-Right>', function()
		vim.print("Right ->")
	end, { desc = "Move to right ->", expr = true })
end

return M
