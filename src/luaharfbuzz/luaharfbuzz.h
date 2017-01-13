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

// Functions to create classes and push them onto the stack
int register_class(lua_State *L, const char *name, const luaL_Reg * methods, const luaL_Reg *functions);
int register_blob(lua_State *L);
int register_face(lua_State *L);
int register_font(lua_State *L);
int register_buffer(lua_State *L);
int register_feature(lua_State *L);


