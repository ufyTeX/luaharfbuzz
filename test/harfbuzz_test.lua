harfbuzz = require('luaharfbuzz')
pl = require('pl.pretty')

print("Using harfbuzz version", harfbuzz.version())

local fontfile = io.open(arg[1], "r")
local fontdata = fontfile:read("*all")
fontfile:close()

local text = arg[2]

local glyphs = { harfbuzz._shape(text, fontdata, 0) }

print("No. of glyphs", #glyphs)

pl.dump(glyphs)
