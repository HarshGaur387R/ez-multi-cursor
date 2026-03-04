M = {}
State = false

--- Check if text insertion allowed or not
---@return boolean
function M.getState()
	return State
end

--- Set boolean value of state
---@param value boolean
function M.setState(value)
	State = value
end

return M
