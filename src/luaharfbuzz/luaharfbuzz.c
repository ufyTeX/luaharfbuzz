#include "luaharfbuzz.h"

int _shape (lua_State *L) {
  // Extract font and text
  size_t font_l;
  const char * text = luaL_checkstring(L, 1);
  const char * font_s = luaL_checklstring(L, 2, &font_l);
  unsigned int font_index = luaL_checknumber(L, 3);

  /* Create font. */
  hb_blob_t* blob = hb_blob_create (font_s, font_l, HB_MEMORY_MODE_WRITABLE, (void*)font_s, NULL);
  hb_face_t* hb_face = hb_face_create (blob, font_index);
  hb_font_t *hb_font = hb_font_create (hb_face);
  unsigned int upem = hb_face_get_upem(hb_face);
  hb_font_set_scale(hb_font, upem, upem);
  hb_ot_font_set_funcs(hb_font);

  /* Create hb-buffer and populate. */
  hb_buffer_t *hb_buffer;
  hb_buffer = hb_buffer_create ();
  hb_buffer_add_utf8 (hb_buffer, text, strlen(text), 0, strlen(text));
  hb_buffer_guess_segment_properties (hb_buffer);

  /* Shape it! */
  hb_shape (hb_font, hb_buffer, NULL, 0);

  /* Get glyph information and positions out of the buffer. */
  unsigned int len = hb_buffer_get_length (hb_buffer);
  hb_glyph_info_t *info = hb_buffer_get_glyph_infos (hb_buffer, NULL);
  hb_glyph_position_t *pos = hb_buffer_get_glyph_positions (hb_buffer, NULL);

  // Create Lua table and push glyph data onto it.
  int r = lua_checkstack(L, len);
  if (!r) {
    lua_pushstring(L, "Cannot allocate space on stack");
    lua_error(L);
  }

  for (unsigned int i = 0; i < len; i++)
  {
    hb_glyph_extents_t extents = {0,0,0,0};
    hb_font_get_glyph_extents(hb_font, info[i].codepoint, &extents);

    lua_newtable(L);

    lua_setfield_generic("gid", info[i].codepoint);
    lua_setfield_generic("cl", info[i].cluster);
    lua_setfield_generic("ax", pos[i].x_advance);
    lua_setfield_generic("ay", pos[i].y_advance);
    lua_setfield_generic("dx", pos[i].x_offset);
    lua_setfield_generic("dy", pos[i].y_offset);
    lua_setfield_generic("w", extents.width);
    lua_setfield_generic("h", extents.height);
    lua_setfield_generic("xb", extents.x_bearing);
    lua_setfield_generic("yb", extents.y_bearing);
  }

  hb_buffer_destroy (hb_buffer);
  hb_font_destroy (hb_font);

  return len;
}

int shape (lua_State *L) {
  Font *font = (Font *)luaL_checkudata(L, 1, "harfbuzz.Font");
  Buffer *buf = (Buffer *)luaL_checkudata(L, 2, "harfbuzz.Buffer");

  // Shape text
  hb_shape (*font, *buf, NULL, 0);

  // Get glyph info and positions out of buffer
  unsigned int len = hb_buffer_get_length(*buf);
  hb_glyph_info_t *info = hb_buffer_get_glyph_infos(*buf, NULL);
  hb_glyph_position_t *pos = hb_buffer_get_glyph_positions(*buf, NULL);

  // Create Lua table and push glyph data onto it.
  int r = lua_checkstack(L, len);
  if (!r) {
    lua_pushstring(L, "Cannot allocate space on stack");
    lua_error(L);
  }

  for (unsigned int i = 0; i < len; i++)
  {
    lua_newtable(L);

    lua_setfield_generic("codepoint", info[i].codepoint);
    lua_setfield_generic("cluster", info[i].cluster);
    lua_setfield_generic("x_advance", pos[i].x_advance);
    lua_setfield_generic("y_advance", pos[i].y_advance);
    lua_setfield_generic("x_offset", pos[i].x_offset);
    lua_setfield_generic("y_offset", pos[i].y_offset);
  }

  return len;
}

int version (lua_State *L) {
  lua_pushstring(L, hb_version_string());
  return 1;
}

int list_shapers (lua_State *L) {
  const char **shaper_list = hb_shape_list_shapers ();
  int i = 0;

  for (; *shaper_list; shaper_list++) {
    i++;
    lua_pushstring(L, *shaper_list);
  }
  return i;
}

static const struct luaL_Reg lib_table [] = {
  {"_shape", _shape}, // Deprecated
  {"shape", shape},
  {"version", version},
  {"shapers", list_shapers},
  {NULL, NULL}
};

int luaopen_luaharfbuzz (lua_State *L) {
  lua_newtable(L);

  register_blob(L);
  lua_setfield(L, -2, "Blob");

  register_face(L);
  lua_setfield(L, -2, "Face");

  register_font(L);
  lua_setfield(L, -2, "Font");

  register_buffer(L);
  lua_setfield(L, -2, "Buffer");

  luaL_setfuncs(L, lib_table,0);

  return 1;
}

