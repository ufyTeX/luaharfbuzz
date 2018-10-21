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
      assert.are_equal(string.len(s), blob:get_length())
    end)
  end)

  describe("harfbuzz.Face", function()
    local face = harfbuzz.Face.new('fonts/notonastaliq.ttf')
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
      assert.are_equal(2048,face:get_upem())
    end)

    it("can return table tags", function()
      local t = face:get_table_tags()
      assert.are_equal(14,#t)
      assert.are_equal("GDEF",tostring(t[1]))
      assert.are_equal("post",tostring(t[#t]))
    end)

    it("can return glyph count", function()
      assert.are_equal(1133,face:get_glyph_count())
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

    it("can get glyph extents using get_glyph_extents", function()
      local font = harfbuzz.Font.new(face)
      local extents = font:get_glyph_extents(0)
      assert.are_equal(145, extents.x_bearing)
      assert.are_equal(2452, extents.y_bearing)
      assert.are_equal(1553, extents.width)
      assert.are_equal(-2452, extents.height)
      extents = font:get_glyph_extents(1)
      assert.are_equal(0, extents.x_bearing)
      assert.are_equal(0, extents.y_bearing)
      assert.are_equal(0, extents.width)
      assert.are_equal(0, extents.height)
    end)

    it("can get glyph name using get_glyph_name", function()
      local font = harfbuzz.Font.new(face)
      assert.are_equal(".notdef", font:get_glyph_name(0))
      assert.are_equal("null", font:get_glyph_name(1))
    end)

    it("can get glyph advance using get_glyph_h_advance", function()
      local font = harfbuzz.Font.new(face)
      assert.are_equal(1843, font:get_glyph_h_advance(0))
      assert.are_equal(0, font:get_glyph_h_advance(1))
    end)

    it("can get glyph advance using get_glyph_v_advance", function()
      local font = harfbuzz.Font.new(face)
      assert.are_equal(-2048, font:get_glyph_v_advance(0))
      assert.are_equal(-2048, font:get_glyph_v_advance(1))
    end)
  end)

  describe("harfbuzz.Feature", function()
    it("can be initialised with a valid feature string", function()
      harfbuzz.Feature.new('kern')
      harfbuzz.Feature.new('+kern')
    end)

    it("throws an error when trying to initialise a new Feature with an invalid string", function()
       assert.has_error(function() harfbuzz.Feature.new('') end)
       assert.has_error(function() harfbuzz.Feature.new('#kern') end, "Invalid feature string")
    end)

    it("has a valid tostring value", function()
      local fs = 'kern'
      local f = harfbuzz.Feature.new(fs)
      assert.are_equal(fs, tostring(f))
    end)
  end)

  describe("harfbuzz.Tag", function()
    it("can be initialised with a valid tag string", function()
      harfbuzz.Tag.new('Zyyy')
    end)

    it("can be initialised to HB_TAG_NONE with nil or empty argument", function()
      local t = harfbuzz.Tag.new()
      assert.are_equal(harfbuzz.Tag.HB_TAG_NONE, t)
      t = harfbuzz.Tag.new(nil)
      assert.are_equal(harfbuzz.Tag.HB_TAG_NONE, t)
    end)

    it("has a valid tostring value", function()
      local ts = 'Arab'
      local t = harfbuzz.Tag.new(ts)
      assert.are_equal(ts, tostring(t))
    end)

    it("has a valid equality check functions", function()
      local ts = 'Arab'
      local t1 = harfbuzz.Tag.new(ts)
      local t2 = harfbuzz.Tag.new(ts)
      local t3 = harfbuzz.Tag.new("Latn")
      assert.are_equal(t1, t2)
      assert.are_not_equal(t1, t3)
    end)

    it("has a preset value for HB_TAG_NONE", function()
      local n = harfbuzz.Tag.HB_TAG_NONE
      assert.is_not_nil(n)
      assert.are_equal("", tostring(n))
      assert.are_equal(harfbuzz.Tag.HB_TAG_NONE, harfbuzz.Tag.new(""))
    end)
  end)

  describe("harfbuzz.Script", function()
    it("can be initialised with a string", function()
      harfbuzz.Script.new('Arab')
    end)

    it("can be initialised to HB_SCRIPT_INVALID with nil or empty argument", function()
      local t = harfbuzz.Script.new()
      assert.are_equal(harfbuzz.Script.HB_SCRIPT_INVALID, t)
      t = harfbuzz.Script.new(nil)
      assert.are_equal(harfbuzz.Script.HB_SCRIPT_INVALID, t)
    end)

    it("can be initialised with a tag", function()
      local ts = "Arab"
      local s = harfbuzz.Script.from_iso15924_tag(harfbuzz.Tag.new(ts))
      assert.are_equal(ts, tostring(s))
    end)

    it("can be converted to a tag", function()
      local s = 'Arab'
      local sc = harfbuzz.Script.new(s)
      assert.are_equal(s, tostring(sc:to_iso15924_tag()))
    end)

    it("has a valid tostring value", function()
      local ts = 'Arab'
      local t = harfbuzz.Script.new(ts)
      assert.are_equal(ts, tostring(t))
    end)

    it("has a valid equality check functions", function()
      local ts = 'Arab'
      local t1 = harfbuzz.Script.new(ts)
      local t2 = harfbuzz.Script.new(ts)
      local t3 = harfbuzz.Script.new("Latn")
      assert.are_equal(t1, t2)
      assert.are_not_equal(t1, t3)
    end)
  end)

  describe("harfbuzz.Direction", function()
    it("can be initialised with a valid tag string", function()
      harfbuzz.Direction.new('LTR')
    end)

    it("can be initialised with invalid strings", function()
      local d1 = harfbuzz.Direction.new("i")
      local d2 = harfbuzz.Direction.new("inv")

      assert.are_equal(d1, d2)
      assert.are_equal("invalid", tostring(d1))
    end)

    it("has a valid tostring value", function()
      local ts = 'ltr'
      local t = harfbuzz.Direction.new(ts)
      assert.are_equal(ts, tostring(t))

      t = harfbuzz.Direction.new("LTR")
      assert.are_equal(ts, tostring(t))
    end)

    it("has a valid equality check functions", function()
      local ts = 'ltr'
      local t1 = harfbuzz.Direction.new(ts)
      local t2 = harfbuzz.Direction.new(ts)
      local t3 = harfbuzz.Direction.new("rtl")
      assert.are_equal(t1, t2)
      assert.are_not_equal(t1, t3)
    end)

    it("has a HB_DIRECTION_IS_INVALID function", function()
      assert.True(harfbuzz.Direction.HB_DIRECTION_IS_VALID(harfbuzz.Direction.HB_DIRECTION_LTR))
      assert.False(harfbuzz.Direction.HB_DIRECTION_IS_VALID(harfbuzz.Direction.HB_DIRECTION_INVALID))
    end)

    it("has a HB_DIRECTION_IS_HORIZONTAL function", function()
      assert.True(harfbuzz.Direction.HB_DIRECTION_IS_HORIZONTAL(harfbuzz.Direction.HB_DIRECTION_LTR))
      assert.False(harfbuzz.Direction.HB_DIRECTION_IS_HORIZONTAL(harfbuzz.Direction.HB_DIRECTION_TTB))
    end)

    it("has a HB_DIRECTION_IS_VERTICAL function", function()
      assert.True(harfbuzz.Direction.HB_DIRECTION_IS_VERTICAL(harfbuzz.Direction.HB_DIRECTION_TTB))
      assert.False(harfbuzz.Direction.HB_DIRECTION_IS_VERTICAL(harfbuzz.Direction.HB_DIRECTION_LTR))
    end)

    it("has a HB_DIRECTION_IS_FORWARD function", function()
      assert.True(harfbuzz.Direction.HB_DIRECTION_IS_FORWARD(harfbuzz.Direction.HB_DIRECTION_LTR))
      assert.False(harfbuzz.Direction.HB_DIRECTION_IS_FORWARD(harfbuzz.Direction.HB_DIRECTION_RTL))
    end)

    it("has a HB_DIRECTION_IS_BACKWARD function", function()
      assert.True(harfbuzz.Direction.HB_DIRECTION_IS_BACKWARD(harfbuzz.Direction.HB_DIRECTION_RTL))
      assert.False(harfbuzz.Direction.HB_DIRECTION_IS_BACKWARD(harfbuzz.Direction.HB_DIRECTION_LTR))
    end)
  end)

  describe("harfbuzz.Language", function()
    it("can be initialised with a valid language string", function()
      harfbuzz.Language.new('urd')
    end)

    it("can be initialised to HB_LANGUAGE_INVALID with nil or empty argument", function()
      local t = harfbuzz.Language.new()
      assert.are_equal(harfbuzz.Language.HB_LANGUAGE_INVALID, t)
      t = harfbuzz.Language.new(nil)
      assert.are_equal(harfbuzz.Language.HB_LANGUAGE_INVALID, t)
    end)

    it("has a valid tostring value", function()
      local ts = 'urd'
      local t = harfbuzz.Language.new(ts)
      assert.are_equal(ts, tostring(t))
    end)

    it("has a valid equality check functions", function()
      local ts = 'urd'
      local t1 = harfbuzz.Language.new(ts)
      local t2 = harfbuzz.Language.new(ts)
      local t3 = harfbuzz.Language.new("hin")
      assert.are_equal(t1, t2)
      assert.are_not_equal(t1, t3)
    end)

    it("has a preset value for HB_LANGUAGE_INVALID", function()
      local n = harfbuzz.Language.HB_LANGUAGE_INVALID
      assert.is_not_nil(n)
      assert.are_equal(harfbuzz.Language.HB_LANGUAGE_INVALID, harfbuzz.Language.new())
    end)
  end)

  describe("harfbuzz.unicode", function()
    describe("script function returns a valid script for a codepoint",function()
      local s = harfbuzz.unicode.script(0x0020)
      assert.are_equal(harfbuzz.Script.HB_SCRIPT_COMMON, s)
      s = harfbuzz.unicode.script(0x0041)
      assert.are_equal(harfbuzz.Script.new("Latn"), s)
    end)
  end)
end)

