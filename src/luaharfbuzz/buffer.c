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
	{"__gc", buffer_destroy },
  {"add_utf8", buffer_add_utf8 },
  {"guess_segment_properties", buffer_guess_segment_properties },
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

