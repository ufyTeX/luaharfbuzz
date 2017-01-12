// harfbuzz.Feature
#include "luaharfbuzz.h"

static int feature_new(lua_State *L) {
  const char *feature_string = luaL_checkstring(L, 1);

  Feature f;
  hb_bool_t valid = hb_feature_from_string(feature_string, -1, &f);

  if (!valid) {
    lua_pushstring(L, "Invalid feature string");
    lua_error(L);
  }

  Feature *fp = (Feature *)lua_newuserdata(L, sizeof(*fp));
  luaL_getmetatable(L, "harfbuzz.Feature");
  lua_setmetatable(L, -2);
  *fp = f;

  return 1;
}

static int feature_to_string(lua_State *L) {
  Feature* f = (Feature *)luaL_checkudata(L, 1, "harfbuzz.Feature");

  char feature_string[128];
  hb_feature_to_string(f,feature_string, 128);

  lua_pushstring(L, feature_string);
  return 1;
}

static const struct luaL_Reg feature_methods[] = {
  { "__tostring", feature_to_string },
  { NULL, NULL },
};

static const struct luaL_Reg feature_functions[] = {
  { "new", feature_new },
  { NULL,  NULL }
};

int register_feature(lua_State *L) {
  register_class(L, "harfbuzz.Feature", feature_methods, feature_functions);
  return 1;
}

