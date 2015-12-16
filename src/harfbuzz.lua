local hb = require("luaharfbuzz")

function hb.Face.new(file, font_index)
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

  -- Guess segment properties, in case all steps above have failed
  -- to set the right properties.
  buf:guess_segment_properties()

  local features = {}

  -- Parse features
  if type(options.features) == "string" then
    for fs in string.gmatch(options.features, '([^,]+)') do
      table.insert(features, hb.Feature.new(fs))
    end
  elseif type(options.features) == "table" then
    features = options.features
  elseif options.features then -- non-nil but not a string or table
    error("Invalid features option")
  end

  return hb.shape_full(font,buf,features)
end

return hb
