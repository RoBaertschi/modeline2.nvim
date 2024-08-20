local M = {}
local strings = require("string")


---Checks if "string" contains "contains".
---@param string string
---@param contains string
---@return boolean
---@return integer
M.contains = function(string, contains)
	for i = 1, #string do
		local current_sub = string:sub(i, #contains + i - 1)

		if current_sub == contains then
			return true, i
		end
	end
	return false, -1
end

string:contains = function (string, contains)
	return M.contains(string, contains)
end

---Determine if the provided string contains modeline2 settings.
---@param string string
---@return boolean
M.is_modeline_string = function(string)
	local contained, pos = M.contains(string, "ml2")
	if contained or pos == -1 then
		return false
	end

	return true
end

return M
