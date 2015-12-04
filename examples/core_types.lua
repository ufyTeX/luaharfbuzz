local harfbuzz = require('harfbuzz')
local pl = require('pl.pretty') -- luarocks install penlight

-- Harfbuzz API Version
print("Harfbuzz API version", harfbuzz.version())

-- Shapers available
print("Shapers:")
pl.dump({ harfbuzz.shapers() })

-- harfbuzz.Face
local face = harfbuzz.Face.new('fonts/notonastaliq.ttf')
print('Face upem = '..face:get_upem())

-- harfbuzz.Font
local font = harfbuzz.Font.new(face)
local xs, xy = font:get_scale()
print("Default font scale = X: "..xs..", Y: "..xy)

-- harfbuzz.Buffer
local text = "یہ" -- U+06CC U+06C1
local buf = harfbuzz.Buffer.new()
buf:add_utf8(text)
buf:guess_segment_properties()

-- harfbuzz.shape (Shapes text)
print("Shaping '"..text.."' set with Noto Nastaliq Urdu")
local glyphs = { harfbuzz.shape(font, buf) }

print("No. of glyphs", #glyphs)
pl.dump(glyphs)

