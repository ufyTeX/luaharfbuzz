#include "luaharfbuzz.h"

int shape_full (lua_State *L) {
  Font *font = (Font *)luaL_checkudata(L, 1, "harfbuzz.Font");
  Buffer *buf = (Buffer *)luaL_checkudata(L, 2, "harfbuzz.Buffer");
  luaL_checktype(L, 3, LUA_TTABLE);

  lua_len (L, 3);
  unsigned int num_features = luaL_checkint(L, 4);
  lua_pop(L, 1);

  Feature *features = (Feature *) malloc (num_features * sizeof(hb_feature_t));

  lua_pushnil(L); int i = 0;
  while (lua_next(L, 3) != 0) {
    Feature* f = (Feature *)luaL_checkudata(L, -1, "harfbuzz.Feature");
    features[i++] = *f;
    lua_pop(L, 1);
  }

  // Shape text
  hb_shape_full(*font, *buf, features, num_features, NULL);

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

  free(features);

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
  {"shape_full", shape_full},
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

  register_feature(L);
  lua_setfield(L, -2, "Feature");
  luaL_setfuncs(L, lib_table,0);

  return 1;
}

