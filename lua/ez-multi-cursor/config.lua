-- Configuration module for ez-multi-cursor
local M = {}

-- Default configuration
M.config = {
    highlight_group = 'Visual',
    insert_mode_keys = true,
}

--- Setup configuration with user options
---@param opts table
---@return table
function M.setup(opts)
    opts = opts or {}
    M.config = vim.tbl_extend("force", M.config, opts)
    return M.config
end

return M
