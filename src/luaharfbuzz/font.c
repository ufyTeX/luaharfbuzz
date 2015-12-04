#include "luaharfbuzz.h"

static int font_new(lua_State *L) {
  Font *f;
  Face *face = luaL_checkudata(L, 1, "harfbuzz.Face");

  f = (Font *)lua_newuserdata(L, sizeof(*f));
  luaL_getmetatable(L, "harfbuzz.Font");
  lua_setmetatable(L, -2);

  *f = hb_font_create(*face);

  // Set default scale to be the face's upem value
  unsigned int upem = hb_face_get_upem(*face);
  hb_font_set_scale(*f, upem, upem);

  // Set shaping functions to OpenType functions
  hb_ot_font_set_funcs(*f);
  return 1;
}

static int font_set_scale(lua_State *L) {
  Font *f = (Font *)luaL_checkudata(L, 1, "harfbuzz.Font");
  int x_scale = luaL_checkint(L, 2);
  int y_scale = luaL_checkint(L, 3);

  hb_font_set_scale(*f, x_scale, y_scale);
  return 0;
}

static int font_get_scale(lua_State *L) {
  Font *f = (Font *)luaL_checkudata(L, 1, "harfbuzz.Font");
  int x_scale, y_scale;

  hb_font_get_scale(*f,&x_scale, &y_scale);

  lua_pushinteger(L, x_scale);
  lua_pushinteger(L, y_scale);
  return 2;
}


static int font_destroy(lua_State *L) {
  Font *f;
  f = (Font *)luaL_checkudata(L, 1, "harfbuzz.Font");

  hb_font_destroy(*f);

  return 0;
}

static const struct luaL_Reg font_methods[] = {
	{"__gc", font_destroy },
  {"set_scale", font_set_scale },
  {"get_scale", font_get_scale },
  { NULL, NULL },
};

static const struct luaL_Reg font_functions[] = {
  { "new", font_new },
  { NULL,  NULL }
};

int register_font(lua_State *L) {
  luaL_newmetatable(L, "harfbuzz.Font");
  lua_pushvalue(L, -1);
  lua_setfield(L, -2, "__index");

  luaL_setfuncs(L, font_methods, 0);
  lua_pop(L,1);

  luaL_newlib(L, font_functions);
  return 1;
}


