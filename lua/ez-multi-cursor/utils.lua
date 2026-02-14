-- Utility functions for ez-multi-cursor
local M = {}

--- Get_line function returns a line indexed at line_number
---@param line_number integer
---@param buf integer
---@return string
function M.get_line(line_number, buf)
    local start = line_number - 1
    local finish = line_number
    local lines = vim.api.nvim_buf_get_lines(buf, start, finish, false)
    return lines[1] or ""
end

--- Replace_line: Replace a specific line in the current buffer.
---@param line_number integer  -- 1-based line number
---@param new_text string      -- replacement text
---@param bufnr integer        -- buffer number
---@return string -- Newly created line
function M.replace_line(line_number, new_text, bufnr)
    local start = line_number - 1
    local finish = line_number

    -- Replace the line
    vim.api.nvim_buf_set_lines(bufnr, start, finish, false, { new_text })
    local lines = vim.api.nvim_buf_get_lines(bufnr, start, finish, false)

    return lines[1] or ""
end

return M
