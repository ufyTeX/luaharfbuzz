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

    it("can return unicode characters supported by face", function()
      local u = face:collect_unicodes()
      assert.are_equal(267,#u)
      assert.are_equal(0x0000,u[1])
      assert.are_equal(0xFEFF,u[#u])
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

    it("can get font extents", function()
      local font = harfbuzz.Font.new(face)
      local extents = font:get_h_extents(0)
      assert.are_equal(3900, extents.ascender)
      assert.are_equal(-1220, extents.descender)
      assert.are_equal(0, extents.line_gap)
      extents = font:get_v_extents(1)
      assert.are_equal(nil, extents)
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

    it("can get nominal glyph for codepoint", function()
      local font = harfbuzz.Font.new(face)
      assert.are_equal(nil, font:get_nominal_glyph(0x0041))
      assert.are_equal(858, font:get_nominal_glyph(0x0627))
    end)
  end)

  describe("harfbuzz.Feature", function()
    it("can be initialised with a valid feature string", function()
      harfbuzz.Feature.new('kern')
      harfbuzz.Feature.new('+kern')
    end)

    it("throws an error when trying to initialise a new Feature with an invalid string", function()
       assert.are_equal(nil, harfbuzz.Feature.new(''))
       assert.are_equal(nil, harfbuzz.Feature.new('#kern'))
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

    it("can be initialised to NONE with nil or empty argument", function()
      local t = harfbuzz.Tag.new()
      assert.are_equal(harfbuzz.Tag.NONE, t)
      t = harfbuzz.Tag.new(nil)
      assert.are_equal(harfbuzz.Tag.NONE, t)
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

    it("has a preset value for NONE", function()
      local n = harfbuzz.Tag.NONE
      assert.is_not_nil(n)
      assert.are_equal("", tostring(n))
      assert.are_equal(harfbuzz.Tag.NONE, harfbuzz.Tag.new(""))
    end)
  end)

  describe("harfbuzz.Script", function()
    it("can be initialised with a string", function()
      harfbuzz.Script.new('Arab')
    end)

    it("can be initialised to INVALID with nil or empty argument", function()
      local t = harfbuzz.Script.new()
      assert.are_equal(harfbuzz.Script.INVALID, t)
      t = harfbuzz.Script.new(nil)
      assert.are_equal(harfbuzz.Script.INVALID, t)
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

    it("has a is_valid function", function()
      assert.True(harfbuzz.Direction.is_valid(harfbuzz.Direction.LTR))
      assert.False(harfbuzz.Direction.is_valid(harfbuzz.Direction.INVALID))
    end)

    it("has a is_horizontal function", function()
      assert.True(harfbuzz.Direction.is_horizontal(harfbuzz.Direction.LTR))
      assert.False(harfbuzz.Direction.is_horizontal(harfbuzz.Direction.TTB))
    end)

    it("has a is_vertical function", function()
      assert.True(harfbuzz.Direction.is_vertical(harfbuzz.Direction.TTB))
      assert.False(harfbuzz.Direction.is_vertical(harfbuzz.Direction.LTR))
    end)

    it("has a is_forward function", function()
      assert.True(harfbuzz.Direction.is_forward(harfbuzz.Direction.LTR))
      assert.False(harfbuzz.Direction.is_forward(harfbuzz.Direction.RTL))
    end)

    it("has a is_backward function", function()
      assert.True(harfbuzz.Direction.is_backward(harfbuzz.Direction.RTL))
      assert.False(harfbuzz.Direction.is_backward(harfbuzz.Direction.LTR))
    end)
  end)

  describe("harfbuzz.Language", function()
    it("can be initialised with a valid language string", function()
      harfbuzz.Language.new('urd')
    end)

    it("can be initialised to INVALID with nil or empty argument", function()
      local t = harfbuzz.Language.new()
      assert.are_equal(harfbuzz.Language.INVALID, t)
      t = harfbuzz.Language.new(nil)
      assert.are_equal(harfbuzz.Language.INVALID, t)
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

    it("has a preset value for INVALID", function()
      local n = harfbuzz.Language.INVALID
      assert.is_not_nil(n)
      assert.are_equal(harfbuzz.Language.INVALID, harfbuzz.Language.new())
    end)
  end)

  describe("harfbuzz.unicode", function()
    describe("script function returns a valid script for a codepoint",function()
      local s = harfbuzz.unicode.script(0x0020)
      assert.are_equal(harfbuzz.Script.COMMON, s)
      s = harfbuzz.unicode.script(0x0041)
      assert.are_equal(harfbuzz.Script.new("Latn"), s)
    end)
  end)
end)

