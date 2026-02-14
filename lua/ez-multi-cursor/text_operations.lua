-- Text operations module for ez-multi-cursor
local Rendering = require("ez-multi-cursor.rendering")

local M = {}

--- InsertText function insert text at the given cursors positions
---@param cursors table
---@param str string
function M.insert_text(cursors, str)
    for i = 1, #cursors do
        local cursor = cursors[i]
        local position = Rendering.get_position_of_extmarks(cursor.cursorId, cursor.buf)
        local row, col = position[1], position[2]

        -- Replace text at [row, col] with inserted string
        vim.api.nvim_buf_set_text(
            cursor.buf,
            row, col, -- start position
            row, col, -- end position (same col → pure insertion)
            { str } -- replacement text
        )
    end
end

return M
