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

int shape (lua_State *L) {
  // Extract font and text
  size_t font_l;
  const char * text = luaL_checkstring(L, 1);
  const char * font_s = luaL_checklstring(L, 2, &font_l);
  unsigned int font_index = luaL_checknumber(L, 3);

  /* Create font. */
  hb_blob_t* blob = hb_blob_create (font_s, font_l, HB_MEMORY_MODE_WRITABLE, (void*)font_s, NULL);
  hb_face_t* hb_face = hb_face_create (blob, font_index);
  hb_font_t *hb_font = hb_font_create (hb_face);
  unsigned int upem = hb_face_get_upem(hb_face);
  hb_font_set_scale(hb_font, upem, upem);
  hb_ot_font_set_funcs(hb_font);

  /* Create hb-buffer and populate. */
  hb_buffer_t *hb_buffer;
  hb_buffer = hb_buffer_create ();
  hb_buffer_add_utf8 (hb_buffer, text, strlen(text), 0, strlen(text));
  hb_buffer_guess_segment_properties (hb_buffer);

  /* Shape it! */
  hb_shape (hb_font, hb_buffer, NULL, 0);

  /* Get glyph information and positions out of the buffer. */
  unsigned int len = hb_buffer_get_length (hb_buffer);
  hb_glyph_info_t *info = hb_buffer_get_glyph_infos (hb_buffer, NULL);
  hb_glyph_position_t *pos = hb_buffer_get_glyph_positions (hb_buffer, NULL);

  // Create Lua table and push glyph data onto it.
  int r = lua_checkstack(L, len);
  if (!r) {
    lua_pushstring(L, "Cannot allocate space on stack");
    lua_error(L);
  }

  for (unsigned int i = 0; i < len; i++)
  {
    hb_glyph_extents_t extents = {0,0,0,0};
    hb_font_get_glyph_extents(hb_font, info[i].codepoint, &extents);

    lua_newtable(L);

    lua_setfield_generic("gid", info[i].codepoint);
    lua_setfield_generic("cl", info[i].cluster);
    lua_setfield_generic("ax", pos[i].x_advance);
    lua_setfield_generic("ay", pos[i].y_advance);
    lua_setfield_generic("dx", pos[i].x_offset);
    lua_setfield_generic("dy", pos[i].y_offset);
    lua_setfield_generic("w", extents.width);
    lua_setfield_generic("h", extents.height);
    lua_setfield_generic("xb", extents.x_bearing);
    lua_setfield_generic("yb", extents.y_bearing);
  }

  hb_buffer_destroy (hb_buffer);
  hb_font_destroy (hb_font);

  return len;
}

typedef hb_blob_t* blob;

static int blob_new(lua_State *L) {
  blob *b;
  size_t data_l;

  const char * data = luaL_checklstring(L, 1, &data_l);

  b = (blob *)lua_newuserdata(L, sizeof(*b));
  /* Add the metatable to the stack. */
  luaL_getmetatable(L, "harfbuzz.Blob");
  /* Set the metatable on the userdata. */
  lua_setmetatable(L, -2);

  *b = hb_blob_create(data, data_l, HB_MEMORY_MODE_DUPLICATE, (void*)data, NULL);
  return 1;
}

static int blob_length(lua_State *L) {
  blob *b;
  b = (blob *)luaL_checkudata(L, 1, "harfbuzz.Blob");
  lua_pushinteger(L, hb_blob_get_length(*b));
  return 1;
}

static int blob_destroy(lua_State *L) {
  blob *b;
  b = (blob *)luaL_checkudata(L, 1, "harfbuzz.Blob");

  hb_blob_destroy(*b);

  return 0;
}

int get_harfbuzz_version (lua_State *L) {
  unsigned int major;
  unsigned int minor;
  unsigned int micro;
  char version[256];
  hb_version(&major, &minor, &micro);
  sprintf(version, "%i.%i.%i", major, minor, micro);
  lua_pushstring(L, version);
  return 1;
}

int list_shapers (lua_State *L) {
  const char **shaper_list = hb_shape_list_shapers ();
  int i = 0;

  for (; *shaper_list; shaper_list++) {
    i++;
    lua_pushstring(L, *shaper_list);
  }
  return i;
}

static const struct luaL_Reg blob_methods[] = {
  { "length", blob_length },
	{"__gc", blob_destroy },
  { NULL, NULL },
};

static const struct luaL_Reg blob_functions[] = {
  { "new", blob_new },
  { NULL,  NULL }
};

static const struct luaL_Reg lib_table [] = {
  {"_shape", shape},
  {"version", get_harfbuzz_version},
  {"shapers", list_shapers},
  {NULL, NULL}
};

int register_blob(lua_State *L) {
  /* Create the metatable and put it on the stack. */
  luaL_newmetatable(L, "harfbuzz.Blob");
  /* Duplicate the metatable on the stack (We know have 2). */
  lua_pushvalue(L, -1);
  /* Pop the first metatable off the stack and assign it to __index
   * of the second one. We set the metatable for the table to itself.
   * This is equivalent to the following in lua:
   * metatable = {}
   * metatable.__index = metatable
   */
  lua_setfield(L, -2, "__index");

  /* Set the methods to the metatable that should be accessed via object:func */
  luaL_setfuncs(L, blob_methods, 0);

  luaL_newlib(L, blob_functions);
  return 1;
}

int luaopen_luaharfbuzz (lua_State *L) {
  lua_newtable(L);

  register_blob(L);
  lua_setfield(L, -2, "Blob");

  luaL_setfuncs(L, lib_table,0);
  return 1;
}

