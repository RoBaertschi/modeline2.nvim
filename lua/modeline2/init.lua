local M = {
	key_value_seperator = "=",
	---@type {[string]: function}
	custom_functions = {},
}

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
---@field key_value_seperator? string  Default is "=", should only be one char long
---@field custom_functions? {[string]: function} Functions that can be used with the "lua" action

---@param config? Config
M.setup = function(config)
	if config == nil then
		return
	end

	if config.key_value_seperator then
		M.key_value_seperator = config.key_value_seperator
	end

	if config.custom_functions then
		M.custom_functions = config.custom_functions
	end
end

---@type {[string]: ActionType}
local with_value_actions = {
	ft = "filetype",
	tw = "textwidth",
	sts = "softtabstop",
	ts = "tabstop",
	sw = "shiftwidth",
	fdm = "foldmethod",
	filetype = "filetype",
	textwidth = "textwidth",
	softtabstop = "softtabstop",
	tabstop = "tabstop",
	shiftwidth = "shiftwidth",
	foldmethod = "foldmethod",
	lua = "lua",
}

---@type {[string]: ActionType}
local no_value_actions = {
	et = "expandtab",
	noet = "noexpandtab",
	ro = "readonly",
	noro = "noreadonly",
	rl = "rightleft",
	norl = "norightleft",
	expandtab = "expandtab",
	noexpandtab = "noexpandtab",
	readonly = "readonly",
	noreadonly = "noreadonly",
	rightleft = "rightleft",
	norightleft = "norightleft",
}

---@alias ActionType "lua"|"filetype"|"textwidth"|"softtabstop"|"tabstop"|"shiftwidth"|"expandtab"|"noexpandtab"|"foldmethod"|"readonly"|"noreadonly"|"rightleft"|"norightleft"
---@class Action
---@field type ActionType
---@field value string

--- parse "key=value "
---@param string string
---@param cur_pos integer
---@return string, string?, integer
M.parse_action = function(string, cur_pos)
	local parsed_key = ""

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

---@param key any
---@param tab table
---@return boolean
local function key_in_table(key, tab)
	for tab_key, value in pairs(tab) do
		if key == tab_key then
			return true
		end
	end
	return false
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
	local found_end = false
	local cur_pos = pos + #"ml2"

	local function skipSpaces()
		while string:sub(cur_pos, cur_pos) == " " do
			if #string <= cur_pos then
				found_end = true
			end

			cur_pos = cur_pos + 1
		end
	end

	while true do
		-- skip over stuff like "ml2       ft=vim" to the f
		skipSpaces()
		if found_end then
			break
		end

		local key, value, new_pos = M.parse_action(string, cur_pos)
		cur_pos = new_pos

		if value then
			if key_in_table(key, with_value_actions) then
				table.insert(found_actions, { type = with_value_actions[key], value = value })
			else
				print("[modeline2] Error: could not find key with value action type " .. key)
				return false, {}
			end
		else
			if key_in_table(key, no_value_actions) then
				table.insert(found_actions, { type = no_value_actions[key], value = nil })
			else
				print("[modeline2] Error: could not find boolean action type " .. key)
				return false, {}
			end
		end

		if #string <= cur_pos then
			break
		end
	end

	return true, found_actions
end

---@param actions Action[]
---@return boolean Could all actions be executed successfully
M.execute_actions = function(actions)
	for i, action in ipairs(actions) do
		if action.type == "lua" then
		elseif action.type == "tabstop" then
			vim.opt.tabstop = action.value
		elseif action.type == "filetype" then
		end
	end

	return true
end

return M
