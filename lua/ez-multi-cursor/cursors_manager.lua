-- Cursor collection manager for ez-multi-cursor
local Cursor = require("ez-multi-cursor.cursor")
local Rendering = require("ez-multi-cursor.rendering")
local Utils = require("ez-multi-cursor.utils")

local M = {}

-- Storing multiple cursors positions
M.cursors = {}

--- Finds the index of cursor in cursors table by its key field
---@param key string
---@return integer
local function find_index(key)
    local index = -1

    for i = 1, #M.cursors, 1 do
        if M.cursors[i].key == key then
            index = i
            break
        end
    end

    return index
end

--- Removes a cursor from cursors by given index
---@param index integer
local function remove_cursor_from_cursors(index)
    table.remove(M.cursors, index)
end

--- Adds a new cursor to cursors table
---@param cur table
local function add_new_cursor_in_cursors(cur)
    local cursor = Cursor.new(cur.x_cordinate, cur.y_cordinate, cur.buf, nil, cur.key)
    table.insert(M.cursors, cursor)
end

--- Finds all the cursors at same coordinate from M.cursors
---@param key string
---@return table
local function find_existing_cursors_at_same_cordinate(key)
    local existing_cursors = {}

    for i = 1, #M.cursors, 1 do
        if M.cursors[i].key == key then
            table.insert(existing_cursors, M.cursors[i])
        end
    end

    return existing_cursors
end

--- Adds a cursor in cursor table if cursor doesn't exist, otherwise removes it
function M.add_or_remove_cursor()
    local buf = vim.api.nvim_get_current_buf()
    local current_window = vim.api.nvim_get_current_win()
    local pos = vim.api.nvim_win_get_cursor(current_window)
    local row, col = pos[1], pos[2]
    local current_line = Utils.get_line(row, buf)

    -- Early return for empty lines
    if #current_line == 0 then
        current_line = Utils.replace_line(row, " ", buf)
        col = 0
    end

    -- Early return so col_end wont exceed
    if col == #current_line then return end

    -- Remove Cursor if its already exist
    local key = row .. ":" .. col
    local existing_cursors = find_existing_cursors_at_same_cordinate(key)

    -- If index is smaller than 0, then add new cursor to cursors table.
    if #existing_cursors == 0 then
        add_new_cursor_in_cursors(
            {
                x_cordinate = col,
                y_cordinate = row,
                key = key,
                buf = buf
            }
        )
    else
        for _ = 1, #existing_cursors, 1 do
            local index = find_index(key)
            remove_cursor_from_cursors(index)
        end
    end

    Rendering.un_render_cursors(M.cursors)
    Rendering.render_cursors(M.cursors)
end

--- Clear all cursors
function M.clear_all_cursors()
    M.cursors = {}
end

return M
