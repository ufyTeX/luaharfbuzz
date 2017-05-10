// harfbuzz.Feature
#include "luaharfbuzz.h"

static int direction_new(lua_State *L) {
  const char *direction_string = luaL_checkstring(L, 1);

  Direction *dp = (Direction *)lua_newuserdata(L, sizeof(*dp));
  luaL_getmetatable(L, "harfbuzz.Direction");
  lua_setmetatable(L, -2);

  *dp = hb_direction_from_string(direction_string, -1);

  return 1;
}

static int direction_to_string(lua_State *L) {
  Direction* d = (Direction *)luaL_checkudata(L, 1, "harfbuzz.Direction");
  const char *dir = hb_direction_to_string(*d);

  lua_pushstring(L, dir);
  return 1;
}

static int direction_equals(lua_State *L) {
  Direction* lhs = (Direction *)luaL_checkudata(L, 1, "harfbuzz.Direction");
  Direction* rhs = (Direction *)luaL_checkudata(L, 2, "harfbuzz.Direction");

  if (*lhs == *rhs) {
    lua_pushboolean(L, 1);
  } else {
    lua_pushboolean(L, 0);
  }

  return 1;
}

static int direction_is_valid(lua_State *L) {
    Direction* d = (Direction *)luaL_checkudata(L, 1, "harfbuzz.Direction");
    lua_pushboolean(L, HB_DIRECTION_IS_VALID(*d));
    return 1;
}

static int direction_is_horizontal(lua_State *L) {
    Direction* d = (Direction *)luaL_checkudata(L, 1, "harfbuzz.Direction");
    lua_pushboolean(L, HB_DIRECTION_IS_HORIZONTAL(*d));
    return 1;
}

static int direction_is_vertical(lua_State *L) {
    Direction* d = (Direction *)luaL_checkudata(L, 1, "harfbuzz.Direction");
    lua_pushboolean(L, HB_DIRECTION_IS_VERTICAL(*d));
    return 1;
}

static int direction_is_forward(lua_State *L) {
    Direction* d = (Direction *)luaL_checkudata(L, 1, "harfbuzz.Direction");
    lua_pushboolean(L, HB_DIRECTION_IS_FORWARD(*d));
    return 1;
}

static int direction_is_backward(lua_State *L) {
    Direction* d = (Direction *)luaL_checkudata(L, 1, "harfbuzz.Direction");
    lua_pushboolean(L, HB_DIRECTION_IS_BACKWARD(*d));
    return 1;
}

static const struct luaL_Reg direction_methods[] = {
  { "__tostring", direction_to_string },
  { "__eq", direction_equals },
  { NULL, NULL },
};

static const struct luaL_Reg direction_functions[] = {
  { "new", direction_new },
  { "HB_DIRECTION_IS_VALID", direction_is_valid },
  { "HB_DIRECTION_IS_HORIZONTAL", direction_is_horizontal },
  { "HB_DIRECTION_IS_VERTICAL", direction_is_vertical },
  { "HB_DIRECTION_IS_FORWARD", direction_is_forward },
  { "HB_DIRECTION_IS_BACKWARD", direction_is_backward },
  { NULL,  NULL }
};

int register_direction(lua_State *L) {
  return register_class(L, "harfbuzz.Direction", direction_methods, direction_functions);
}
