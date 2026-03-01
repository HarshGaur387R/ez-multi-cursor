-- Text operations module for ez-multi-cursor
local Rendering = require("ez-multi-cursor.rendering")

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
            { str }   -- replacement text
        )
    end
end

return M
