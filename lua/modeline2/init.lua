local M = {
	key_value_seperator = "=",
	---@type {[string]: fun(event: {buf: integer, file: string})}
	custom_functions = {},
}

local function printErr(...)
	print("[modeline2] Error:", ...)
end

---Checks if "string" contains "contains".
---@param string string
---@param contains string
---@return boolean
---@return integer
local contains = function(string, contains)
	for i = 1, #string do
		local current_sub = string:sub(i, #contains + i - 1)

		if current_sub == contains then
			return true, i
		end
	end
	return false, -1
end

---@class modeline2.Config
---@field key_value_seperator? string  Default is "=", should only be one char long
---@field custom_functions? {[string]: function} Functions that can be used with the "lua" action

---@param config? modeline2.Config
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

	vim.api.nvim_create_autocmd({ "BufEnter", "VimEnter" }, {
		callback = function(ev)
			local strings = vim.api.nvim_buf_get_lines(ev.buf, 0, 5, false)

			for _, string in ipairs(strings) do
				local success, actions = M.get_modeline_string(string)
				if success then
					M.execute_actions(actions, ev)
				end
			end
		end,
	})
end

---@type {[string]: modeline2.ActionType}
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

---@type {[string]: modeline2.ActionType}
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

---@alias modeline2.ActionType "lua"|"filetype"|"textwidth"|"softtabstop"|"tabstop"|"shiftwidth"|"expandtab"|"noexpandtab"|"foldmethod"|"readonly"|"noreadonly"|"rightleft"|"norightleft"
---@class modeline2.Action
---@field type modeline2.ActionType
---@field value string?

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
	for tab_key in pairs(tab) do
		if key == tab_key then
			return true
		end
	end
	return false
end

---Determine if the provided string contains modeline2 settings.
---@param string string
---@return boolean, modeline2.Action[]
M.get_modeline_string = function(string)
	local contained, pos = contains(string, "ml2")
	if not contained or pos == -1 then
		return false, {}
	end

	---@type modeline2.Action[]
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
				printErr("could not find key with value action type " .. key)
				return false, {}
			end
		else
			if key_in_table(key, no_value_actions) then
				table.insert(found_actions, { type = no_value_actions[key], value = nil })
			else
				printErr("could not find boolean action type " .. key)
				return false, {}
			end
		end

		if #string <= cur_pos then
			break
		end
	end

	return true, found_actions
end

---@param actions modeline2.Action[]
---@param event any
---@return boolean Could all actions be executed successfully
M.execute_actions = function(actions, event)
	for _, action in ipairs(actions) do
		if action.type == "lua" then
			local function_to_call = M.custom_functions[action.value]
			if type(function_to_call) == "function" then
				function_to_call({ file = event.file, buf = event.buf })
			else
				printErr('could not find custom lua function "' .. action.value .. '"')
				return false
			end
		elseif
			(action.type == "tabstop")
			or (action.type == "textwidth")
			or (action.type == "softtabstop")
			or (action.type == "shiftwidth")
		then
			local number = tonumber(action.value)
			vim.bo[action.type] = number
		elseif action.type == "filetype" then
			vim.bo.filetype = action.value
		elseif action.type == "foldmethod" then
			vim.bo.foldmethod = action.value
		else
			-- all booleans
			if action.type:sub(1, 2) == "no" then
				vim.bo[action.type:sub(3, #action.type)] = false
			else
				vim.bo[action.type] = true
			end
		end
	end

	return true
end

return M
