#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <hb.h>
#include <hb-ot.h>
#include <string.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

typedef hb_blob_t* Blob;
typedef hb_face_t* Face;
typedef hb_font_t* Font;
typedef hb_buffer_t* Buffer;
typedef hb_feature_t Feature;


#define register_class(L, name, methods, functions)({luaL_newmetatable(L, name); lua_pushvalue(L, -1); lua_setfield(L, -2, "__index"); luaL_setfuncs(L, methods, 0); lua_pop(L,1); luaL_newlib(L, functions); luaL_getmetatable(L, name); lua_setmetatable(L, -2);})

// Functions to create classes and push them onto the stack
int register_blob(lua_State *L);
int register_face(lua_State *L);
int register_font(lua_State *L);
int register_buffer(lua_State *L);
int register_feature(lua_State *L);


