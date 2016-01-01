-- Allow external Lua modules to be loaded.
dofile 'package_path_searcher.lua'

-- Attach a OpenType font loader to define_font callback.
require 'ot_font_loader'

-- Disable some callbacks, and attach debug logging to others.
require 'custom_callbacks'

-- Load luaharfbuzz
local harfbuzz = require 'harfbuzz'

local lt_to_hb_dir = { TLT = "ltr", TRT = "rtl" }
-- local hb_to_lt_dir = { ltr = "TLT", rtl = "TRT" }

-- Print the contents of a nodelist.
-- Glyph nodes are printed as UTF-8 characters, while other nodes are printed
-- by calling node.type on it, along with the subtype of the node.
local function show_nodes (head, raw)
  local nodes = ''
  for item in node.traverse(head) do
    local i = item.id
    if i == node.id("glyph") then
      if raw then i = string.format('<glyph %d>', item.char) else i = unicode.utf8.char(item.char) end
    else
      i = string.format('<%s %s>', node.type(i), ( item.subtype and ("(".. item.subtype .. ")") or ''))
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
local function process_nodes(head)
  -- Pointer to traverse head nodelist
  local headslider = head

  -- First node is a local_par
  assert(headslider.id == node.id("local_par"))

  -- Get direction
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

  -- Pointer to traverse new heade nodelist
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

  -- Initialise new tail at the last penalty node.
  local newtail = headslider.next

  -- Skip over penalty node
  headslider = headslider.next.next

  -- Last node is a \parfillskip
  assert(headslider.id == node.id("glue") and headslider.subtype == 15)
  assert(not headslider.next)

  -- Shape text
  local buf = harfbuzz.Buffer.new()
  buf:add_codepoints(codepoints)
  harfbuzz.shape(font.harfbuzz.font,buf, { direction = lt_to_hb_dir[dir] })

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
local function show_and_process_nodes(head)
  texio.write_nl("No. of nodes: "..node.length(head))
  show_nodes(head)
  return process_nodes(head)
end

-- Register shaping callback
callback.register("pre_linebreak_filter", show_and_process_nodes)


