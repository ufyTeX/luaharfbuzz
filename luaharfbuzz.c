#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <hb-ot.h>
#include <string.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int shape (lua_State *L) {
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

    lua_pushstring(L, "gid");
    lua_pushinteger(L, info[i].codepoint);
    lua_settable(L, -3);
    lua_pushstring(L, "cl");
    lua_pushinteger(L, info[i].cluster);
    lua_settable(L, -3);
    lua_pushstring(L, "ax");
    lua_pushnumber(L, pos[i].x_advance);
    lua_settable(L, -3);
    lua_pushstring(L, "ay");
    lua_pushnumber(L, pos[i].y_advance);
    lua_settable(L, -3);
    lua_pushstring(L, "dx");
    lua_pushnumber(L, pos[i].x_offset);
    lua_settable(L, -3);
    lua_pushstring(L, "dy");
    lua_pushnumber(L, pos[i].y_offset);
    lua_settable(L, -3);
    lua_pushstring(L, "w");
    lua_pushinteger(L, extents.width);
    lua_settable(L, -3);
    lua_pushstring(L, "h");
    lua_pushinteger(L, extents.height);
    lua_settable(L, -3);
    lua_pushstring(L, "yb");
    lua_pushinteger(L, extents.y_bearing);
    lua_settable(L, -3);
    lua_pushstring(L, "xb");
    lua_pushinteger(L, extents.x_bearing);
    lua_settable(L, -3);
  }

  hb_buffer_destroy (hb_buffer);
  hb_font_destroy (hb_font);

  return len;
}

int get_harfbuzz_version (lua_State *L) {
  unsigned int major;
  unsigned int minor;
  unsigned int micro;
  char version[256];
  hb_version(&major, &minor, &micro);
  sprintf(version, "%i.%i.%i", major, minor, micro);
  lua_pushstring(L, version);
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
  {"_shape", shape},
  {"version", get_harfbuzz_version},
  {"shapers", list_shapers},
  {NULL, NULL}
};

int luaopen_luaharfbuzz (lua_State *L) {
  lua_newtable(L);
  luaL_setfuncs(L, lib_table, 0);
  return 1;
}

