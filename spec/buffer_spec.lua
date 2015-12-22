local harfbuzz = require("harfbuzz")

describe("harfbuzz.Buffer", function()
  it("can be created", function()
    harfbuzz.Buffer.new()
  end)

  it("can add a UTF8 string", function()
    local b = harfbuzz.Buffer.new()
    local s = "Some String"
    b:add_utf8(s)
    assert.are_equal(string.len(s), b:get_length())
  end)

  it("can add a UTF 8 string with item_offset", function()
    local b = harfbuzz.Buffer.new()
    local s = "Some String"
    local o = 5
    b:add_utf8(s,o)
    assert.are_equal(string.len(s) - o, b:get_length())
  end)

  it("can add a UTF 8 string with item_length", function()
    local b = harfbuzz.Buffer.new()
    local s = "Some String"
    local o = 5
    local l = 2
    b:add_utf8(s,o,l)
    assert.are_equal(l, b:get_length())
  end)

  it("can call guess_segment_properties", function()
    local b = harfbuzz.Buffer.new()
    b:add_utf8("Some String")
    b:guess_segment_properties()
  end)

  it("can get and set the direction of a buffer", function()
    local b = harfbuzz.Buffer.new()
    b:add_utf8("abc")
    b:set_direction("rtl")
    assert.are_equal("rtl", b:get_direction())
  end)

  it("throws an error if direction is invalid", function()
    local b = harfbuzz.Buffer.new()
    assert.has_error(function() b:set_direction("fff") end, "Invalid direction")
  end)

  it("can get the direction correctly", function()
    local b = harfbuzz.Buffer.new()
    b:add_utf8("یہ")
    b:guess_segment_properties()
    assert.are_equal("rtl", b:get_direction())
  end)

  it("can get and set the language of a buffer", function()
    local b = harfbuzz.Buffer.new()
    b:add_utf8("یہ")
    b:set_language("urd")
    assert.are_equal("urd", b:get_language())
  end)

  it("throws an error if language is invalid", function()
    local b = harfbuzz.Buffer.new()
    assert.has_error(function() b:set_language("") end, "Invalid language")
  end)

  it("can get the language correctly", function()
    local b = harfbuzz.Buffer.new()
    b:add_utf8("یہ")
    b:guess_segment_properties()
  end)

  it("can get and set the script of a buffer", function()
    local b = harfbuzz.Buffer.new()
    b:add_utf8("abc")
    b:set_script("latn")
    assert.are_equal("Latn", b:get_script())
  end)

  it("throws an error if script is invalid", function()
    local b = harfbuzz.Buffer.new()
    assert.has_error(function() b:set_script("xxx") end, "Unknown script")
  end)

  it("can get the script correctly", function()
    local b = harfbuzz.Buffer.new()
    b:add_utf8("یہ")
    assert.are_equal("", b:get_script())
    b:guess_segment_properties()
    assert.are_equal("Arab", b:get_script())
  end)

  it("can reverse the buffer", function()
    local face = harfbuzz.Face.new('fonts/notonastaliq.ttf')
    local font = harfbuzz.Font.new(face)
    local urdu_text = "یہ" -- U+06CC U+06C1
    local options = { language = "urd", script = "Arab", direction = "rtl" }

    local buf= harfbuzz.Buffer.new()
    buf:add_utf8(urdu_text)
    harfbuzz.shape(font, buf, options)
    local orig_glyphs = buf:get_glyph_infos_and_positions()
    buf:reverse()
    local reversed_glyphs = buf:get_glyph_infos_and_positions()

    assert.are_equal(#orig_glyphs, #reversed_glyphs)

    for c = 1, #orig_glyphs do
      local g = orig_glyphs[#orig_glyphs - (c - 1)]
      local r = reversed_glyphs[c]
      assert.are_equal(g.codepoint, r.codepoint)
      assert.are_equal(g.cluster, r.cluster)
      assert.are_equal(g.x_advance, r.x_advance)
      assert.are_equal(g.y_advance, r.y_advance)
      assert.are_equal(g.x_offset, r.x_offset)
      assert.are_equal(g.y_offset, r.y_offset)
    end

  end)

  it("can get the length of the buffer", function()
    local b = harfbuzz.Buffer.new()
    local s = "some string"
    b:add_utf8(s)
    assert.are_equal(string.len(s), b:get_length())
  end)
end)


