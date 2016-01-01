local harfbuzz = require('harfbuzz')

-- Load OpenType font.
-- https://tug.org/TUGboat/tb33-1/tb103isambert.pdf
local function read_font (name, size, fontid)
  if size < 0 then
    size = size * tex.sp("10pt") / -1000
  end

  -- Load file using fontloader.open
  local f = fontloader.open (name)
  local fonttable = fontloader.to_table(f)
  fontloader.close(f)

  local metrics = {
    name = fonttable.fontname,
    fullname = fonttable.fontname..fontid,
    psname = fonttable.fontname,
    type = "real",
    filename = name,
    format = string.match(string.lower(name), "otf$") and "opentype" or string.match(string.lower(name), "ttf$") and "truetype",
    embedding = 'subset',
    size = size,
    designsize = fonttable.design_size*6553.6,
    cidinfo = fonttable.cidinfo
  }

  metrics.parameters = {
    slant = 0,
    space = size * 0.25,  -- FIXME use the glyph width for 0x20 codepoint
    space_stretch = 0.3 * size,
    space_shrink = 0.1 * size,
    x_height = 0.4 * size,
    quad = 1.0 * size,
    extra_space = 0
  }

  metrics.characters = { }

  local mag = size / fonttable.units_per_em
  metrics.units_per_em = fonttable.units_per_em
  local names_of_char = { }
  for _, glyph in pairs(fonttable.map.map) do
    names_of_char[fonttable.glyphs[glyph].name] = fonttable.map.backmap[glyph]
  end
  -- save backmap in TeX font, so we can get char code from glyph index
  -- obtainded from Harfbuzz
  metrics.backmap = fonttable.map.backmap
  for char, glyph in pairs(fonttable.map.map) do
    local glyph_table = fonttable.glyphs[glyph]
    metrics.characters[char] = {
      index = glyph,
      width = glyph_table.width * mag,
      name = glyph_table.name,
    }
    if glyph_table.boundingbox[4] then
      metrics.characters[char].height = glyph_table.boundingbox[4] * mag
    end
    if glyph_table.boundingbox[2] then
      metrics.characters[char].depth = -glyph_table.boundingbox[2] * mag
    end
    if glyph_table.kerns then
      local kerns = { }
      for _, kern in pairs(glyph_table.kerns) do
        kerns[names_of_char[kern.char]] = kern.off * mag
      end
      metrics.characters[char].kerns = kerns
    end
  end

  -- Store Harfbuzz data in the font to retrieve it in the shaping routine.
  local face = harfbuzz.Face.new(name)
  metrics.harfbuzz = {
    face = face,
    font = harfbuzz.Font.new(face)
  }

  return metrics
end

-- Register OpenType font loader in define_font callback.
callback.register('define_font', read_font, "font loader")

