// harfbuzz.Feature
#include "luaharfbuzz.h"

static int language_new(lua_State *L) {
  Language *tp = (Language *)lua_newuserdata(L, sizeof(*tp));
  luaL_getmetatable(L, "harfbuzz.Language");
  lua_setmetatable(L, -2);

  if (lua_gettop(L) == 1 || lua_isnil(L, -2)) {
    *tp = HB_LANGUAGE_INVALID;
  } else {
    const char *language_string = luaL_checkstring(L, -2);
    *tp = hb_language_from_string(language_string, -1);
  }

  return 1;
}

static int language_to_string(lua_State *L) {
  Language* t = (Language *)luaL_checkudata(L, 1, "harfbuzz.Language");
  lua_pushstring(L, hb_language_to_string(*t));
  return 1;
}

static int language_equals(lua_State *L) {
  Language* lhs = (Language *)luaL_checkudata(L, 1, "harfbuzz.Language");
  Language* rhs = (Language *)luaL_checkudata(L, 2, "harfbuzz.Language");

  if (*lhs == *rhs) {
    lua_pushboolean(L, 1);
  } else {
    lua_pushboolean(L, 0);
  }

  return 1;
}

static const struct luaL_Reg language_methods[] = {
  { "__tostring", language_to_string },
  { "__eq", language_equals },
  { NULL, NULL },
};

static const struct luaL_Reg language_functions[] = {
  { "new", language_new },
  { NULL,  NULL }
};

int register_language(lua_State *L) {
  return  register_class(L, "harfbuzz.Language", language_methods, language_functions);
}
