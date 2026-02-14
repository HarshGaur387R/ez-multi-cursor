-- Cursor movement module for ez-multi-cursor
local Utils = require("ez-multi-cursor.utils")
local Rendering = require("ez-multi-cursor.rendering")

local M = {}

--- Sets x coordinate to all the cursors
---@param cursors table
---@param x integer
function M.set_x_cordinate(cursors, x)
    local buffer = vim.api.nvim_get_current_buf();

    for i = 1, #cursors, 1 do
        local cursor = cursors[i]
        local current_line = Utils.get_line(cursor.y_cordinate, buffer)

        if buffer == cursor.buf then
            local new_x = cursor.x_cordinate + x

            -- Check if new position exceeds line length
            if new_x >= #current_line and x > 0 then
                -- Check if last character is already a space
                local last_char = current_line:sub(-1)
                if last_char ~= " " then
                    -- Add a space at the end
                    current_line = current_line .. " "
                    Utils.replace_line(cursor.y_cordinate, current_line, buffer)
                end
            end

            -- Now check if movement is valid
            if (#current_line > new_x) and (new_x >= 0) then
                cursor.x_cordinate = new_x
                local newKey = cursor.y_cordinate .. ":" .. cursor.x_cordinate
                cursor.key = newKey
                cursors[i] = cursor
            end
        end
    end

    Rendering.un_render_cursors(cursors)
    Rendering.render_cursors(cursors)
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
