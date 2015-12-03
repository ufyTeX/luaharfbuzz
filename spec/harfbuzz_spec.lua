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

  describe("harfbuzz.Face", function()
    it("can be initialized with a blob", function()
      local fontfile = io.open('fonts/notonastaliq.ttf', "r")
      local fontdata = fontfile:read("*all")
      fontfile:close()

      local blob = harfbuzz.Blob.new(fontdata)
      harfbuzz.Face.new_from_blob(blob,0)
    end)

    it("can be initialized with a blob and a font index", function()
      harfbuzz.Face.new('fonts/notonastaliq.ttf',0)
    end)

    it("can be initialized with a blob only", function()
      harfbuzz.Face.new('fonts/notonastaliq.ttf')
    end)

    it("returns a valid upem value", function()
      local f = harfbuzz.Face.new('fonts/notonastaliq.ttf')
      assert.are_equal(2048,f:get_upem())
    end)
  end)

end)

