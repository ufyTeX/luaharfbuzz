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

    it("can be initialized with a file and a font index", function()
      harfbuzz.Face.new('fonts/notonastaliq.ttf',0)
    end)

    it("can be initialized with a file only", function()
      harfbuzz.Face.new('fonts/notonastaliq.ttf')
    end)

    it("returns a valid upem value", function()
      local f = harfbuzz.Face.new('fonts/notonastaliq.ttf')
      assert.are_equal(2048,f:get_upem())
    end)
  end)

  describe("harfbuzz.Font", function()
    local face = harfbuzz.Face.new('fonts/notonastaliq.ttf')
    it("can be initialized with a face", function()
      harfbuzz.Font.new(face)
    end)

    it("has a default scale set to the fonts upem", function()
      local font = harfbuzz.Font.new(face)
      local upem = face:get_upem()
      local xs, ys = font:get_scale()
      assert.are_equal(upem, xs)
      assert.are_equal(upem, ys)
    end)

    it("can set the scale of the font using set_scale", function()
      local font = harfbuzz.Font.new(face)
      font:set_scale(1024,2048)
      local xs, ys = font:get_scale()
      assert.are_equal(1024, xs)
      assert.are_equal(2048, ys)
    end)
  end)

  describe("harfbuzz.Feature", function()
    it("can be initialised with a valid feature string", function()
      harfbuzz.Feature.new('kern')
      harfbuzz.Feature.new('+kern')
    end)

    it("throws an error when trying to initialise a new Feature with an invalid string", function()
       assert.has_error(function() harfbuzz.Feature.new('') end)
       assert.has_error(function() harfbuzz.Feature.new('#kern') end)
    end)

    it("has a valid tostring value", function()
      local fs = 'kern'
      local f = harfbuzz.Feature.new(fs)
      assert.are_equal(fs, tostring(f))
    end)
  end)
end)

