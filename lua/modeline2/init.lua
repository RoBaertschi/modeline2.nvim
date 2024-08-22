local M = {
	key_value_seperator = "=",
}
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

---@class Config
---@field key_value_seperator string  Default is "=", should only be one char long

---@param config? Config
M.setup = function(config)
	if config == nil then
		return
	end

	if config.key_value_seperator then
		M.key_value_seperator = config.key_value_seperator
	end
end

---@type string[]
local actions = {
	"filetype",
	"textwidth",
	"softtabstop",
	"tabstop",
	"shiftwidth",
	"expandtab",
	"noexpandtab",
	"foldmethod",
	"readonly",
	"noreadonly",
	"rightleft",
	"norightleft",
}

---@type {[string]: string}
local short_to_action_mapping = {
	ft = "filetype",
	tw = "textwidth",
	sts = "softtabstop",
	ts = "tabstop",
	sw = "shiftwidth",
	et = "expandtab",
	noet = "noexpandtab",
	fdm = "foldmethod",
	ro = "readonly",
	noro = "noreadonly",
	rl = "rightleft",
	norl = "norightleft",
}

---@type string[]
local no_value_actions = {
	"rightleft",
	"norightleft",
	"readonly",
	"noreadonly",
	"expandtab",
	"noexpandtab",
}

---@alias ActionType "lua"|"filetype"|"textwidth"|"softtabstop"|"tabstop"|"shiftwidth"|"expandtab"|"noexpandtab"|"foldmethod"|"readonly"|"noreadonly"|"rightleft"|"norightleft"
---@class Action
---@field type ActionType
---@filed value string

--- parse "key=value "
---@param string string
---@param cur_pos integer
---@return string, string?, integer
M.parse_action = function(string, cur_pos)
	local parsed_key = ""

	local value = string:sub(cur_pos, cur_pos)
	while not (string:sub(cur_pos, cur_pos) == M.key_value_seperator or string:sub(cur_pos, cur_pos) == " ") do
		if #string <= cur_pos then
			parsed_key = parsed_key .. string:sub(cur_pos, cur_pos)
			return parsed_key, nil, cur_pos
		end
		parsed_key = parsed_key .. string:sub(cur_pos, cur_pos)
		cur_pos = cur_pos + 1
	end

	if string:sub(cur_pos, cur_pos) == " " then
		-- We have no value
		return parsed_key, nil, cur_pos
	end

	local parsed_value = ""
	cur_pos = cur_pos + 1

	while not (string:sub(cur_pos, cur_pos) == " ") do
		if #string <= cur_pos then
			parsed_value = parsed_value .. string:sub(cur_pos, cur_pos)
			break
		end

		parsed_value = parsed_value .. string:sub(cur_pos, cur_pos)
		cur_pos = cur_pos + 1
	end

	return parsed_key, parsed_value, cur_pos
end

---Determine if the provided string contains modeline2 settings.
---@param string string
---@return boolean, Action[]
M.get_modeline_string = function(string)
	local contained, pos = M.contains(string, "ml2")
	if not contained or pos == -1 then
		return false, {}
	end

	---@type Action[]
	local found_actions = {}
	local cur_pos = pos + #"ml2"

	if cur_pos > #string then
		return true, actions
	end

	return true, actions
end

return M
