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
  int x_scale = luaL_checkinteger(L, 2);
  int y_scale = luaL_checkinteger(L, 3);

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

static int font_get_glyph_extents(lua_State *L) {
  Font *f = (Font *)luaL_checkudata(L, 1, "harfbuzz.Font");
  hb_codepoint_t glyph = luaL_checkinteger(L, 2);
  hb_glyph_extents_t extents;

  if (hb_font_get_glyph_extents(*f, glyph, &extents)) {
    lua_newtable(L);

    lua_pushnumber(L, extents.x_bearing);
    lua_setfield(L, -2, "x_bearing");

    lua_pushnumber(L, extents.y_bearing);
    lua_setfield(L, -2, "y_bearing");

    lua_pushnumber(L, extents.width);
    lua_setfield(L, -2, "width");

    lua_pushnumber(L, extents.height);
    lua_setfield(L, -2, "height");
  } else {
    lua_pushnil(L);
  }

  return 1;
}

static int font_get_glyph_name(lua_State *L) {
  Font *f = (Font *)luaL_checkudata(L, 1, "harfbuzz.Font");
  hb_codepoint_t glyph = luaL_checkinteger(L, 2);

#define NAME_LEN 128
  char name[NAME_LEN];
  if (hb_font_get_glyph_name(*f, glyph, name, NAME_LEN))
    lua_pushstring(L, name);
  else
    lua_pushnil(L);
#undef NAME_LEN

  return 1;
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
  {"get_glyph_extents", font_get_glyph_extents },
  {"get_glyph_name", font_get_glyph_name },
  { NULL, NULL },
};

static const struct luaL_Reg font_functions[] = {
  { "new", font_new },
  { NULL,  NULL }
};

int register_font(lua_State *L) {
  return register_class(L, "harfbuzz.Font", font_methods, font_functions);
}

