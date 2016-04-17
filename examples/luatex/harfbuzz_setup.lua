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

local function upem_to_sp(v,font)
  return math.floor(v / font.units_per_em * font.size)
end

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
      i = string.format('<%s%s>', node.type(i), ( item.subtype and ("(".. item.subtype .. ")") or ''))
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
  local head_slider = head

  -- First node is a local_par
  assert(head_slider.id == node.id("local_par"), "local_par expected")

  -- Get direction
  local dir = head_slider.dir
  texio.write_nl("direction is: "..dir)


  -- Second node is indentation
  head_slider = head_slider.next
  assert(head_slider.id == node.id("hlist") and head_slider.subtype == 3, "parindent hlist expected")

  -- Check if font can be shaped by Harfbuzz
  local fontid = head_slider.next.font
  texio.write_nl("fontid is "..fontid)
  local font = font.getfont(fontid)
  if not font.harfbuzz then return head end
  texio.write_nl("paragraph can be shaped by Harfbuzz")

  -- Initialise new head
  local new_head = node.copy_list(head, head_slider.next)
  assert(node.length(new_head) == 2, "expected two nodes in new_head")

  -- Pointer to traverse new heade nodelist
  local new_head_slider = node.slide(new_head)

  -- Build text
  local codepoints = { }
  while head_slider.next.id ~= node.id("penalty") do
    head_slider = head_slider.next
    if head_slider.id == node.id("glyph") then
      table.insert(codepoints, head_slider.char)
    elseif head_slider.id == node.id("glue") and head_slider.subtype == 13 then
      table.insert(codepoints, 0x20)
    else
      error(string.format("Cant handle node of type %s, subtype %s", node.type(head_slider.id), tostring(head_slider.subtype)))
    end
  end

  -- Initialise new tail at the last penalty node.
  local new_tail = head_slider.next

  -- Skip over penalty node
  head_slider = head_slider.next.next

  -- Last node is a \parfillskip
  assert(head_slider.id == node.id("glue") and head_slider.subtype == 15, "\\parfillskip expected")
  assert(not head_slider.next, "Expected this to be the last node.")

  -- Shape text
  local buf = harfbuzz.Buffer.new()
  buf:set_cluster_level(harfbuzz.Buffer.HB_BUFFER_CLUSTER_LEVEL_CHARACTERS)
  buf:add_codepoints(codepoints)
  harfbuzz.shape(font.harfbuzz.font,buf, { direction = lt_to_hb_dir[dir] })

  -- Create new nodes from shaped text
  if dir == 'TRT' then buf:reverse() end
  local glyphs = buf:get_glyph_infos_and_positions()

  for _, v in ipairs(glyphs) do
    local n,k -- Node and (optional) Kerning
    local char = font.backmap[v.codepoint]
    if codepoints[v.cluster+1] == 0x20 then
      assert(char == 0x20 or char == 0xa0, "Expected char to be 0x20 or 0xa0")
      n = node.new("glue")
      n.subtype = 0
      n.width = font.parameters.space
      n.stretch = font.parameters.space_stretch
      n.shrink = font.parameters.space_shrink
      new_head_slider.next = n
    else
      -- Create glyph node
      n = node.new("glyph")
      n.font = fontid
      n.char = char
      n.subtype = 1

      -- Set offsets from Harfbuzz data
      n.yoffset = upem_to_sp(v.y_offset, font)
      n.xoffset = upem_to_sp(v.x_offset, font)
      if dir == 'TRT' then n.xoffset = n.xoffset * -1 end

      -- Adjust kerning if Harfbuzz’s x_advance does not match glyph width
      local x_advance = upem_to_sp(v.x_advance, font)
      if  math.abs(x_advance - n.width) > 1 then -- needs kerning
        k = node.new("kern")
        k.kern = (x_advance - n.width)
      end

      -- Insert glyph node into new list,
      -- adjusting for direction and kerning.
      if k then
        if dir == 'TRT' then -- kerning goes before glyph
          k.next = n
          new_head_slider.next = k
        else -- kerning goes after glyph
          n.next = k
          new_head_slider.next = n
        end
      else -- no kerning
        new_head_slider.next = n
      end
    end
    new_head_slider = node.slide(new_head_slider)
  end

  new_head_slider.next = new_tail
  texio.write_nl("No. of nodes after shaping: "..node.length(new_head))
  show_nodes(new_head, true)
  return new_head
end

-- Callback function
local function show_and_process_nodes(head)
  texio.write_nl("No. of nodes: "..node.length(head))
  show_nodes(head)
  return process_nodes(head)
end

-- Register shaping callback
callback.register("pre_linebreak_filter", show_and_process_nodes)


