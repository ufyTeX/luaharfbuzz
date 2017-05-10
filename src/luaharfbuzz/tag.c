// harfbuzz.Feature
#include "luaharfbuzz.h"

static int tag_new(lua_State *L) {
  Tag *tp = (Tag *)lua_newuserdata(L, sizeof(*tp));
  luaL_getmetatable(L, "harfbuzz.Tag");
  lua_setmetatable(L, -2);

  if (lua_gettop(L) == 1 || lua_isnil(L, -2)) {
    *tp = HB_TAG_NONE;
  } else {
    const char *tag_string = luaL_checkstring(L, -2);
    *tp = hb_tag_from_string(tag_string, -1);
  }

  return 1;
}

static int tag_to_string(lua_State *L) {
  Tag* t = (Tag *)luaL_checkudata(L, 1, "harfbuzz.Tag");

  char tag_string[5];
  hb_tag_to_string(*t,tag_string);
  tag_string[4] = '\0';

  lua_pushstring(L, tag_string);
  return 1;
}

static int tag_equals(lua_State *L) {
  Tag* lhs = (Tag *)luaL_checkudata(L, 1, "harfbuzz.Tag");
  Tag* rhs = (Tag *)luaL_checkudata(L, 2, "harfbuzz.Tag");

  if (*lhs == *rhs) {
    lua_pushboolean(L, 1);
  } else {
    lua_pushboolean(L, 0);
  }

  return 1;
}

static const struct luaL_Reg tag_methods[] = {
  { "__tostring", tag_to_string },
  { "__eq", tag_equals },
  { NULL, NULL },
};

static const struct luaL_Reg tag_functions[] = {
  { "new", tag_new },
  { NULL,  NULL }
};

int register_tag(lua_State *L) {
  return  register_class(L, "harfbuzz.Tag", tag_methods, tag_functions);
}
