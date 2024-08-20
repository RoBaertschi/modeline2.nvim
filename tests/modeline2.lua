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
end)
