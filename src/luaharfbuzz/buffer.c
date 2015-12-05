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

static int buffer_add_utf8(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");

  const char *text = luaL_checkstring(L, 2);

  hb_buffer_add_utf8(*b, text, strlen(text), 0, strlen(text));

  return 0;
}

static int buffer_destroy(lua_State *L) {
  Buffer *b = (Buffer *)luaL_checkudata(L, 1, "harfbuzz.Buffer");

  hb_buffer_destroy(*b);

  return 0;
}

static const struct luaL_Reg buffer_methods[] = {
	{ "__gc", buffer_destroy },
  { "add_utf8", buffer_add_utf8 },
  { "set_direction", buffer_set_direction },
  { "get_direction", buffer_get_direction },
  { "set_language", buffer_set_language },
  { "get_language", buffer_get_language },
  { "set_script", buffer_set_script },
  { "get_script", buffer_get_script },
  { "guess_segment_properties", buffer_guess_segment_properties },
  { NULL, NULL },
};

static const struct luaL_Reg buffer_functions[] = {
  { "new", buffer_new },
  { NULL,  NULL }
};

int register_buffer(lua_State *L) {
  luaL_newmetatable(L, "harfbuzz.Buffer");
  lua_pushvalue(L, -1);
  lua_setfield(L, -2, "__index");

  luaL_setfuncs(L, buffer_methods, 0);
  lua_pop(L,1);

  luaL_newlib(L, buffer_functions);
  return 1;
}

