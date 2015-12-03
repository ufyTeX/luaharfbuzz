local harfbuzz = require("harfbuzz")

describe("harfbuzz module", function()

  it("returns a valid version string", function()
    assert.are_equal("string", type(harfbuzz.version()))
  end)

  it("returns a valid list of shapers", function()
    local shapers = { harfbuzz.shapers }
    assert.is_not.True(#shapers == 0)
  end)

  describe("harfbuzz.Blob", function()
    it("can be initialized with a string", function()
      local s = "test string"
      local blob = harfbuzz.Blob.new(s)
      assert.are_equal(string.len(s), blob:length())
    end)
  end)
end)

