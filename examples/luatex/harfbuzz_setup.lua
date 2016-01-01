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

-- Load OpenType font.
-- https://tug.org/TUGboat/tb33-1/tb103isambert.pdf
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

-- Print the contents of a nodelist.
-- Glyph nodes are printed as UTF-8 characters, while other nodes are printed
-- by calling node.type on it, along with the subtype of the node.
function show_nodes (head, raw)
  local nodes = ""
  for item in node.traverse(head) do
    local i = item.id
    if i == node.id("glyph") then
      if raw then i = '<glyph ' .. item.char .. '>' else i = unicode.utf8.char(item.char) end
    else
      i = '<' .. node.type(i) .. ( item.subtype and ("(".. item.subtype .. ")") or '') .. '>'
    end
    nodes = nodes .. i .. ' '
  end
  texio.write_nl(nodes)
  return true
end

-- Process a paragraph nodelist and shape it with Harfbuzz.
-- Only works for the most simple paragraphs. Check the assertions in the code
-- to understand what kind of nodes the shaping routine is expecting at
-- any point.
function process_nodes(head)
  -- Store a pointer to head
  local headslider = head

  -- First node is a local_par
  assert(headslider.id == node.id("local_par"))

  -- Get direction
  local dir_map = { TLT = "ltr", TRT = "rtl" }
  local dir = headslider.dir
  texio.write_nl("direction is: "..dir)

  -- Second node is indentation glue
  headslider = headslider.next
  assert(headslider.id == node.id("hlist") and headslider.subtype == 3)

  -- Check if font can be shaped by Harfbuzz
  local fontid = headslider.next.font
  texio.write_nl("fontid is "..fontid)
  local font = font.getfont(fontid)
  if not font.harfbuzz then return head end
  texio.write_nl("paragraph can be shaped by Harfbuzz")

  -- Initialise new head
  local newhead = node.copy_list(head, headslider.next)
  assert(node.length(newhead) == 2)
  local newheadslider = node.slide(newhead)

  -- Build text
  local codepoints = { }
  while headslider.next.id ~= node.id("penalty") do
    headslider = headslider.next
    if headslider.id == node.id("glyph") then
      table.insert(codepoints, headslider.char)
    elseif headslider.id == node.id("glue") and headslider.subtype == 0 then
      table.insert(codepoints, 0x20)
    else
      error("Cant handle node of type "..node.type(headslider.id))
    end
  end

  -- Initialise new tail
  local newtail = headslider.next
  -- Skip over penalty node
  headslider = headslider.next.next

  -- Last node is a \parfillskip
  assert(headslider.id == node.id("glue") and headslider.subtype == 15)
  assert(not headslider.next)

  -- Shape text
  local buf = harfbuzz.Buffer.new()
  buf:add_codepoints(codepoints)
  harfbuzz.shape(font.harfbuzz.font,buf, { direction = dir_map[dir] })

  -- Create new nodes from shaped text
  if dir == 'TRT' then buf:reverse() end
  local glyphs = buf:get_glyph_infos_and_positions()

  for _, v in ipairs(glyphs) do
    local n,k -- Node and (optional) Kerning
    local char = font.backmap[v.codepoint]
    if codepoints[v.cluster+1] == 0x20 then
      assert(char == 0x20 or char == 0xa0)
      n = node.new("glue")
      n.subtype = 0
      n.width = font.parameters.space
      n.stretch = font.parameters.space_stretch
      n.shrink = font.parameters.space_shrink
      newheadslider.next = n
    else
      -- Create glyph node
      n = node.new("glyph")
      n.font = fontid
      n.char = char
      n.subtype = 1

      -- Set offsets from Harfbuzz data
      n.yoffset = math.floor(v.y_offset / font.units_per_em * font.size)
      n.xoffset = math.floor(v.x_offset / font.units_per_em * font.size)
      if dir == 'TRT' then n.xoffset = n.xoffset * -1 end

      -- Adjust kerning if Harfbuzz’s x_advance does not match glyph width
      local x_advance = math.floor(v.x_advance / font.units_per_em * font.size)
      if  math.abs(x_advance - n.width) > 1 then -- needs kerning
        k = node.new("kern")
        k.kern = (x_advance - n.width)
      end

      -- Insert glyph node into new list,
      -- adjusting for direction and kerning.
      if k then
        if dir == 'TRT' then -- kerning goes before glyph
          k.next = n
          newheadslider.next = k
        else -- kerning goes after glyph
          n.next = k
          newheadslider.next = n
        end
      else -- no kerning
        newheadslider.next = n
      end
    end
    newheadslider = node.slide(newheadslider)
  end

  newheadslider.next = newtail
  texio.write_nl("No. of nodes after shaping: "..node.length(newhead))
  return newhead
end

-- Callback function
function show_and_process_nodes(head)
  texio.write_nl("No. of nodes: "..node.length(head))
  show_nodes(head)
  return process_nodes(head)
end

-- Register shaping callback
callback.register("pre_linebreak_filter", show_and_process_nodes)

-- Switch off some callbacks
callback.register("hyphenate", false)
callback.register("ligaturing", false)
callback.register("kerning", false)

-- Add debug statements to some callbacks
callback.register("post_linebreak_filter", function()
  texio.write_nl("POST_LINEBREAK")
  return true
end)

callback.register("hpack_filter", function() texio.write_nl("HPACK")
  return true
end)

callback.register("vpack_filter", function() texio.write_nl("VPACK")
  return true
end)

callback.register("buildpage_filter", function(extrainfo) texio.write_nl("BUILDPAGE_FILTER "..extrainfo) end)
