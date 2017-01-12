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

static int blob_get_length(lua_State *L) {
  Blob *b;
  b = (Blob *)luaL_checkudata(L, 1, "harfbuzz.Blob");
  lua_pushinteger(L, hb_blob_get_length(*b));
  return 1;
}

static const struct luaL_Reg blob_methods[] = {
  { "get_length", blob_get_length },
  { NULL, NULL },
};

static const struct luaL_Reg blob_functions[] = {
  { "new", blob_new },
  { NULL,  NULL }
};

int register_blob(lua_State *L) {
  register_class(L, "harfbuzz.Blob", blob_methods, blob_functions);
  return 1;
}

