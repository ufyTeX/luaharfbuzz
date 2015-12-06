local harfbuzz = require("harfbuzz")

local compare_glyphs_against_fixture = function(glyphs, fixture)
  local json = require('dkjson')
  local f = io.open(fixture)
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
end


describe("harfbuzz module shaping functions", function()
  local face = harfbuzz.Face.new('fonts/notonastaliq.ttf')
  local font = harfbuzz.Font.new(face)
  local urdu_text = "یہ" -- U+06CC U+06C1

  it("can take a buffer and font and shape it, with output matching hb-shape", function()
    local buf = harfbuzz.Buffer.new()
    buf:add_utf8(urdu_text)

    local glyphs = { harfbuzz.shape(font, buf) }
    assert.True(#glyphs > 0)

    -- Compare against output of hb-shape
    compare_glyphs_against_fixture(glyphs, 'fixtures/notonastaliq_U06CC_U06C1.json')
  end)

  it("can take a buffer, font and an options table with script, language and direction settings.", function()
    local buf = harfbuzz.Buffer.new()
    buf:add_utf8(urdu_text)

    local glyphs = { harfbuzz.shape(font, buf, { language = "urd", script = "Arab", direction = "rtl" }) }
    assert.True(#glyphs > 0)

    -- Compare against output of hb-shape
    compare_glyphs_against_fixture(glyphs, 'fixtures/notonastaliq_U06CC_U06C1.json')
  end)

end)
