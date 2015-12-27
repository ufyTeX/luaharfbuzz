-- Package Loading References:
-- 1. http://www.lua.org/manual/5.2/manual.html#pdf-package.searchers
-- 2. LuaTeX Manual, Section 2.2, Lua behavior
local make_loader = function(path, pos,loadfunc)
  local default_loader = package.searchers[pos]
  local loader = function(name)
    local file, msg = package.searchpath(name,path)
    if not file then
      local msg = "\n\t[lualoader] Search failed"
      local ret = default_loader(name)
      if type(ret) == "string" then
        return msg ..ret
        elseif type(ret) == "nil" then
          return msg
        else
          return ret
        end
      end
      local loader,err = loadfunc(file)
      if not loader then
        return "\n\t[lualoader] Loading error:\n\t"..err
      end
      return loader
  end
    package.searchers[pos] = loader
end

local binary_loader = function(file)
  local base = file:match("/([^%.]+)%.[%w]+$")
  local symbol = base:gsub("%.","_")
  return package.loadlib(file, "luaopen_"..symbol)
end

make_loader(package.path,2,loadfile)
make_loader(package.cpath,3, binary_loader)

-- Load harfbuzz from standard package path.
local harfbuzz = require('harfbuzz')

-- Load some debug tools
local serpent = require('serpent')
local print_table = function(t)
  texio.write(serpent.block(t, {comment = false}))
end

function read_font (name, size, fontid)
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
    space = size * 0.25,
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
  for char, glyph in pairs(fonttable.map.map) do
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

  local face = harfbuzz.Face.new(name)
  metrics.harfbuzz = {
    face = face,
    font = harfbuzz.Font.new(face)
  }

  return metrics
end

callback.register('define_font', read_font, "font loader")


local GLYF = node.id("glyph")
function show_nodes (head)
  local nodes = ""
  for item in node.traverse(head) do
    local i = item.id
    nodes = nodes .. i .. "("..(item.subtype or '')..")".." "
  end
  texio.write_nl(nodes)
  return true
end

callback.register("hyphenate", nil)
callback.register("ligaturing", nil)
callback.register("kerning", nil)
callback.register("pre_linebreak_filter", show_nodes)

callback.register("buildpage_filter", function(extrainfo) texio.write_nl("BUILDPAGE_FILTER "..extrainfo) end)
