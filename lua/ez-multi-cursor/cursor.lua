---@class Cursor
---@field x_cordinate integer
---@field y_cordinate integer
---@field buf integer
---@field key string
---@field cursorId? integer
local Cursor = {}
Cursor.__index = Cursor


--- Cursor Class construction creates a instance on this Class.
---@param x_cordinate integer
---@param y_cordinate integer
---@param buf integer
---@param cursorId? integer
---@param key string
---@return table
function Cursor.new(x_cordinate, y_cordinate, buf, cursorId, key)
    local instance = setmetatable({}, Cursor)

    instance.x_cordinate = x_cordinate
    instance.y_cordinate = y_cordinate
    instance.buf = buf
    instance.cursorId = cursorId
    instance.key = key

    return instance
end

return Cursor
