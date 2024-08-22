---@module "plenary"
describe("utils", function()
	local ml2 = require("modeline2")

	before_each(function()
		package.loaded.modeline2 = nil
		ml2 = require("modeline2")
	end)

	it("M#contains", function()
		local test = "hello world"
		assert.is_true(ml2.contains(test, "world"))
		assert.is_false(ml2.contains(test, "llod"))
		local _, pos = ml2.contains(test, "world")
		assert.equals(pos, 7)
	end)

	it("M#parse_action key value with space", function()
		local key_value = "test=test2 "
		local key, value, pos = ml2.parse_action(key_value, 1)
		assert.equals("test", key)
		assert.equals("test2", value)
		assert.equals(11, pos)
	end)

	it("M#parse_action key value without space", function()
		local key_value = "test=test2"
		local key, value, pos = ml2.parse_action(key_value, 1)
		assert.equals("test", key)
		assert.equals("test2", value)
		assert.equals(10, pos)
	end)

	it("M#parse_action key with space", function()
		local key_value = "test "
		local key, value, pos = ml2.parse_action(key_value, 1)
		assert.equals("test", key)
		assert.equals(nil, value)
		assert.equals(5, pos)
	end)

	it("M#parse_action key without space", function()
		local key_value = "test"
		local key, value, pos = ml2.parse_action(key_value, 1)
		assert.equals("test", key)
		assert.equals(nil, value)
		assert.equals(4, pos)
	end)

	it("M#get_modeline_string one key to value", function()
		local test = "  ml2 lua=test  "
		local found, actions = ml2.get_modeline_string(test)

		assert.is_true(found)
		assert.same({ { type = "lua", value = "test" } }, actions)
	end)

	it("M#get_modeline_string multiple key to values", function()
		local test = "  ml2 lua=test  ft=vim ts=0"
		local found, actions = ml2.get_modeline_string(test)

		assert.is_true(found)
		assert.same({
			{ type = "lua", value = "test" },
			{ type = "filetype", value = "vim" },
			{ type = "tabstop", value = "0" },
		}, actions)
	end)

	it("M#get_modeline_string with boolean values", function()
		local test = "  ml2    noet  "
		local found, actions = ml2.get_modeline_string(test)

		assert.is_true(found)
		assert.same({ { type = "noexpandtab", value = nil } }, actions)
	end)

	it("M#get_modeline_string multiple booleans", function()
		local test = "  ml2 noet   et noet "
		local found, actions = ml2.get_modeline_string(test)

		assert.is_true(found)
		assert.same({
			{ type = "noexpandtab", value = nil },
			{ type = "expandtab", value = nil },
			{ type = "noexpandtab", value = nil },
		}, actions)
	end)

	it("M#get_modeline_string mixed", function()
		local test = "  ml2 noet  ft=vim et noet filetype=txt"
		local found, actions = ml2.get_modeline_string(test)

		assert.is_true(found)
		assert.same({
			{ type = "noexpandtab", value = nil },
			{ type = "filetype", value = "vim" },
			{ type = "expandtab", value = nil },
			{ type = "noexpandtab", value = nil },
			{ type = "filetype", value = "txt" },
		}, actions)
	end)

	it("M#get_modeline_string mixed with different seperator", function()
		ml2.key_value_seperator = "-"
		local test = "  ml2 noet  ft-vim et noet filetype-txt"
		local found, actions = ml2.get_modeline_string(test)

		assert.is_true(found)
		assert.same({
			{ type = "noexpandtab", value = nil },
			{ type = "filetype", value = "vim" },
			{ type = "expandtab", value = nil },
			{ type = "noexpandtab", value = nil },
			{ type = "filetype", value = "txt" },
		}, actions)
	end)
end)
