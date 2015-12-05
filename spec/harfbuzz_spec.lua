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

  it("can take a buffer and font and shape it, with output matching hb-shape", function()
    local face = harfbuzz.Face.new('fonts/notonastaliq.ttf')
    local font = harfbuzz.Font.new(face)

    local text = "یہ" -- U+06CC U+06C1
    local buf = harfbuzz.Buffer.new()
    buf:add_utf8(text)
    buf:guess_segment_properties()

    local glyphs = { harfbuzz.shape(font, buf) }
    assert.True(#glyphs > 0)

    -- Compare against output of hb-shape
    local json = require('dkjson')
    local f = io.open('fixtures/notonastaliq_U06CC_U06C1.json')
    local s = f:read("*all")
    f:close()
    local hb_shape_glyphs = json.decode(s)
    assert.are_equal(#hb_shape_glyphs, #glyphs)
    for c = 1, #glyphs do
      local g = glyphs[c]
      local h = hb_shape_glyphs[c]
      assert.are_equal(h.g, g.codepoint)
      assert.are_equal(h.cl, g.cluster)
      assert.are_equal(h.ax, g.x_advance)
      assert.are_equal(h.ay, g.y_advance)
      assert.are_equal(h.dx, g.x_offset)
      assert.are_equal(h.dy, g.y_offset)
    end
  end)
end)

