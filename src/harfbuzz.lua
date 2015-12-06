local hb = require("luaharfbuzz")

local Face = hb.Face

-- Extend Face to accept a file name and optional font index
-- in the constructor.
Face.new = function(file, font_index)
  local i = font_index or 0
  local fontfile = io.open(file, "r")
  local fontdata = fontfile:read("*all")
  fontfile:close()

  local blob = hb.Blob.new(fontdata)

  return hb.Face.new_from_blob(blob,i)
end

hb.shape = function(font, buf, options)
  options = options or { }

  -- Apply options to buffer if they are set.
  if options.language then buf:set_language(options.language) end
  if options.script then buf:set_script(options.script) end
  if options.direction then buf:set_direction(options.direction) end

  -- Guess segment properties, incase all steps above have failed
  -- to set the right properties.
  buf:guess_segment_properties()

  return hb.shape_full(font,buf)
end

return hb
