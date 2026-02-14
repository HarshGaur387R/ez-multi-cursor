-- Rendering and highlighting module for ez-multi-cursor
local M = {}

M.namespace = vim.api.nvim_create_namespace("ez-multi-cursor")

--- Add_Highlight function shows a vertical cursor bar using virtual text
---@param row integer
---@param col integer
---@param buf integer
---@return integer
function M.add_highlight(row, col, buf)
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
function M.remove_highlight(cursorId, buf)
    local current_buff = vim.api.nvim_get_current_buf()
    if buf == current_buff then
        vim.api.nvim_buf_del_extmark(buf, M.namespace, cursorId)
    end
end

--- Render_cursors render all the cursor on nvim window
---@param cursors table
function M.render_cursors(cursors)
    for i = 1, #cursors, 1 do
        local c = cursors[i]
        local id = M.add_highlight(c.y_cordinate - 1, c.x_cordinate, c.buf)
        cursors[i].cursorId = id
    end
end

--- Un_render_cursors: This function un-render all the cursors from nvim window
---@param cursors table
function M.un_render_cursors(cursors)
    local current_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(current_buf, M.namespace, 0, -1)
    for i = 1, #cursors, 1 do
        if cursors[i].cursorId then
            M.remove_highlight(cursors[i].cursorId, cursors[i].buf)
            cursors[i].cursorId = nil
        end
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

return M
