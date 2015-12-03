#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "harfbuzz/hb.h"
#include "harfbuzz/hb-ot.h"
#include <string.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

// Taken from http://stackoverflow.com/questions/34021480/any-tips-to-reduce-repetition-when-using-lua-c-functions/34021760#34021760
#define lua_push(X) _Generic((X), \
  const char*: lua_pushstring, \
  float: lua_pushnumber, \
  double: lua_pushnumber, \
  int: lua_pushinteger, \
  unsigned int: lua_pushinteger)(L, X)

#define lua_setfield_generic(NAME, X) \
  lua_push(X); \
  lua_setfield(L, -2, NAME);

// Creates a Blob class and pushes it onto the virtual stack
int register_blob(lua_State *L);

