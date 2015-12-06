#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <hb.h>
#include <hb-ot.h>
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


typedef hb_blob_t* Blob;
typedef hb_face_t* Face;
typedef hb_font_t* Font;
typedef hb_buffer_t* Buffer;

// Functions to create classes and push them onto the stack
int register_class(lua_State *L, const char *name, const luaL_Reg * methods, const luaL_Reg *functions);
int register_blob(lua_State *L);
int register_face(lua_State *L);
int register_font(lua_State *L);
int register_buffer(lua_State *L);


