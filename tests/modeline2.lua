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
end)
