local hb = require("luaharfbuzz")

local Face = hb.Face

--- Extends Face to accept a file name and optional font index
-- in the constructor.
function Face.new(file, font_index)
  local i = font_index or 0
  local fontfile = io.open(file, "r")
  local fontdata = fontfile:read("*all")
  fontfile:close()

  local blob = hb.Blob.new(fontdata)

  return hb.Face.new_from_blob(blob,i)
end

--- Lua wrapper around Harfbuzz’s hb_shape_full() function. Take language,
--  script, direction and feature string in an optional argument. Sets up the
--  buffer correctly, creates the features by parsing the features string and
--  passes it on to hb_shape_full().
--
--  Returns a table containing shaped glyphs.
hb.shape = function(font, buf, options)
  options = options or { }

  -- Apply options to buffer if they are set.
  if options.language then buf:set_language(options.language) end
  if options.script then buf:set_script(options.script) end
  if options.direction then buf:set_direction(options.direction) end

  -- Guess segment properties, in case all steps above have failed
  -- to set the right properties.
  buf:guess_segment_properties()

  return { hb.shape_full(font,buf) }
end

return hb
