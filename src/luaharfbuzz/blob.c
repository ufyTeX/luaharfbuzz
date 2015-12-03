#include "luaharfbuzz.h"

static int blob_new(lua_State *L) {
  Blob *b;
  size_t data_l;

  const char * data = luaL_checklstring(L, 1, &data_l);

  b = (Blob *)lua_newuserdata(L, sizeof(*b));
  luaL_getmetatable(L, "harfbuzz.Blob");
  lua_setmetatable(L, -2);

  *b = hb_blob_create(data, data_l, HB_MEMORY_MODE_DUPLICATE, (void*)data, NULL);
  return 1;
}

static int blob_length(lua_State *L) {
  Blob *b;
  b = (Blob *)luaL_checkudata(L, 1, "harfbuzz.Blob");
  lua_pushinteger(L, hb_blob_get_length(*b));
  return 1;
}

static int blob_destroy(lua_State *L) {
  Blob *b;
  b = (Blob *)luaL_checkudata(L, 1, "harfbuzz.Blob");

  hb_blob_destroy(*b);

  return 0;
}

static const struct luaL_Reg blob_methods[] = {
  { "length", blob_length },
	{"__gc", blob_destroy },
  { NULL, NULL },
};

static const struct luaL_Reg blob_functions[] = {
  { "new", blob_new },
  { NULL,  NULL }
};

int register_blob(lua_State *L) {
  luaL_newmetatable(L, "harfbuzz.Blob");
  lua_pushvalue(L, -1);
  lua_setfield(L, -2, "__index");

  luaL_setfuncs(L, blob_methods, 0);
  lua_pop(L,1);

  luaL_newlib(L, blob_functions);
  return 1;
}

