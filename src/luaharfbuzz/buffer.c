#include "luaharfbuzz.h"

static int buffer_new(lua_State *L) {
  Buffer *b;


  b = (Buffer *)lua_newuserdata(L, sizeof(*b));
  luaL_getmetatable(L, "harfbuzz.Buffer");
  lua_setmetatable(L, -2);

  *b = hb_buffer_create();

   return 1;
}

static int buffer_guess_segment_properties(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");

  hb_buffer_guess_segment_properties(*b);

  return 0;
}

static int buffer_get_direction(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");

  lua_pushstring(L,hb_direction_to_string(hb_buffer_get_direction(*b)));

  return 1;
}

static int buffer_set_direction(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");
  const char* d = luaL_checkstring(L, 2);
  hb_direction_t dir  = hb_direction_from_string(d, strlen(d));

  if (dir == HB_DIRECTION_INVALID) {
    lua_pushstring(L, "Invalid direction");
    lua_error(L);
  }

  hb_buffer_set_direction(*b, dir);

  return 0;
}

static int buffer_get_language(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");

  lua_pushstring(L,hb_language_to_string(hb_buffer_get_language(*b)));

  return 1;
}

static int buffer_set_language(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");
  const char* l = luaL_checkstring(L, 2);
  hb_language_t lang  = hb_language_from_string(l, strlen(l));

  if (lang == HB_LANGUAGE_INVALID) {
    lua_pushstring(L, "Invalid language");
    lua_error(L);
  }

  hb_buffer_set_language(*b, lang);

  return 0;
}

static int buffer_get_script(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");
  char s[128];
  hb_tag_to_string(hb_script_to_iso15924_tag(hb_buffer_get_script(*b)),s);
  s[4] = '\0';
  lua_pushstring(L,s);

  return 1;
}

static int buffer_set_script(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");
  const char* s = luaL_checkstring(L, 2);
  hb_script_t script  = hb_script_from_string(s, strlen(s));

  if (script == HB_SCRIPT_UNKNOWN) {
    lua_pushstring(L, "Unknown script");
    lua_error(L);
  }

  hb_buffer_set_script(*b, script);

  return 0;
}

static int buffer_add_codepoints(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");
  luaL_checktype(L, 2, LUA_TTABLE);
  unsigned int item_offset = luaL_checkinteger(L,3);
  int item_length = luaL_checkinteger(L,4);

  lua_len (L, 2);
  unsigned int n = luaL_checkinteger(L, -1);
  lua_pop(L, 1);

  hb_codepoint_t *text = (hb_codepoint_t *) malloc(n * sizeof(hb_codepoint_t));

  lua_pushnil(L); int i = 0;
  while (lua_next(L, 2) != 0) {
    hb_codepoint_t c = (hb_codepoint_t) luaL_checkinteger(L, -1);
    text[i++] = c;
    lua_pop(L, 1);
  }

  hb_buffer_add_codepoints(*b, text, n, item_offset, item_length);

  free(text);

  return 0;
}

static int buffer_add_utf8(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");

  const char *text = luaL_checkstring(L, 2);
  unsigned int item_offset = luaL_checkinteger(L,3);
  int item_length = luaL_checkinteger(L,4);

  hb_buffer_add_utf8(*b, text, -1, item_offset, item_length);

  return 0;
}

static int buffer_destroy(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");

  hb_buffer_destroy(*b);

  return 0;
}

static int buffer_get_glyph_infos_and_positions(lua_State *L) {
  Buffer *buf = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");

  // Get glyph info and positions out of buffer
  unsigned int len = hb_buffer_get_length(*buf);
  hb_glyph_info_t *info = hb_buffer_get_glyph_infos(*buf, NULL);
  hb_glyph_position_t *pos = hb_buffer_get_glyph_positions(*buf, NULL);

  // Create Lua table and push glyph data onto it.
  lua_newtable(L); // parent table

  unsigned int i;

  for (i = 0; i < len; i++) {
    lua_pushinteger(L, i+1); // 1-indexed key parent table
    lua_newtable(L);        // child table

    lua_pushinteger(L, info[i].codepoint);
    lua_setfield(L, -2, "codepoint");

    lua_pushinteger(L, info[i].cluster);
    lua_setfield(L, -2, "cluster");
    
    lua_pushnumber(L, pos[i].x_advance);
    lua_setfield(L, -2, "x_advance");
    
    lua_pushnumber(L, pos[i].y_advance);
    lua_setfield(L, -2, "y_advance");
    
    lua_pushnumber(L, pos[i].x_offset);
    lua_setfield(L, -2, "x_offset");
    
    lua_pushnumber(L, pos[i].y_offset);
    lua_setfield(L, -2, "y_offset");

    lua_settable(L,-3); // Add child table at index i+1 to parent table
  }

  return 1;
}

static int buffer_reverse(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");

  hb_buffer_reverse(*b);

  return 0;
}

static int buffer_get_length(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");

  lua_pushinteger(L, hb_buffer_get_length(*b));

  return 1;
}

static int buffer_get_cluster_level(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");

  lua_pushinteger(L, hb_buffer_get_cluster_level(*b));

  return 1;
}

static int buffer_set_cluster_level(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");

  unsigned int l = luaL_checkinteger(L, 2);

  hb_buffer_set_cluster_level(*b, l);

  return 0;
}

static const struct luaL_Reg buffer_methods[] = {
  { "__gc", buffer_destroy },
  { "add_utf8_c", buffer_add_utf8 },
  { "add_codepoints_c", buffer_add_codepoints },
  { "set_direction", buffer_set_direction },
  { "get_direction", buffer_get_direction },
  { "set_language", buffer_set_language },
  { "get_language", buffer_get_language },
  { "set_script", buffer_set_script },
  { "get_script", buffer_get_script },
  { "get_glyph_infos_and_positions", buffer_get_glyph_infos_and_positions },
  { "guess_segment_properties", buffer_guess_segment_properties },
  { "reverse", buffer_reverse },
  { "get_length", buffer_get_length },
  { "get_cluster_level", buffer_get_cluster_level },
  { "set_cluster_level", buffer_set_cluster_level },
  { NULL, NULL }
};

static const struct luaL_Reg buffer_functions[] = {
  { "new", buffer_new },
  { NULL,  NULL }
};

int register_buffer(lua_State *L) {
  return register_class(L, "harfbuzz.Buffer", buffer_methods, buffer_functions);
}

