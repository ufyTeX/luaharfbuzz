#include "luaharfbuzz.h"

/* Size of static arrays we use to avoid heap allocating memory when reading
 * data from HarfBuzz. */
#define STATIC_ARRAY_SIZE 128

static int face_new(lua_State *L) {
  Face *f;
  hb_blob_t *blob;
  unsigned int face_index = 0;
  const char *file_name = luaL_checkstring(L, 1);

  if (lua_gettop(L) > 1)
    face_index = (unsigned int) luaL_checkinteger(L, 2);

  blob = hb_blob_create_from_file(file_name);

  if (face_index && face_index >= hb_face_count(blob)) {
    lua_pushnil(L);
  } else {
    f = (Face *)lua_newuserdata(L, sizeof(*f));
    luaL_getmetatable(L, "harfbuzz.Face");
    lua_setmetatable(L, -2);

    *f = hb_face_create(blob, face_index);
  }
  return 1;
}

static int face_new_from_blob(lua_State *L) {
  Face *f;
  Blob *blob = luaL_checkudata(L, 1, "harfbuzz.Blob");
  unsigned int face_index = 0;

  if (lua_gettop(L) > 1)
    face_index = (unsigned int) luaL_checkinteger(L, 2);

  if (face_index && face_index >= hb_face_count(*blob)) {
    lua_pushnil(L);
  } else {
    f = (Face *)lua_newuserdata(L, sizeof(*f));
    luaL_getmetatable(L, "harfbuzz.Face");
    lua_setmetatable(L, -2);

    *f = hb_face_create(*blob, face_index);
  }
  return 1;
}

static int face_get_glyph_count(lua_State *L) {
  Face *f = (Face *)luaL_checkudata(L, 1, "harfbuzz.Face");

  lua_pushinteger(L, hb_face_get_glyph_count(*f));
  return 1;
}

static int face_get_name(lua_State *L) {
  Face *f = (Face *)luaL_checkudata(L, 1, "harfbuzz.Face");
  hb_ot_name_id_t name_id = (hb_ot_name_id_t) luaL_checkinteger(L, 2);
  hb_language_t lang = HB_LANGUAGE_INVALID;
  char name[STATIC_ARRAY_SIZE];
  int text_size = STATIC_ARRAY_SIZE, len;

  if (lua_gettop(L) > 2)
    lang = *((Language*)luaL_checkudata(L, 3, "harfbuzz.Language"));

  len = hb_ot_name_get_utf8(*f, name_id, lang, &text_size, name);
  if (len) {
    if (len < STATIC_ARRAY_SIZE) {
      lua_pushstring(L, name);
    } else {
      char *name = malloc(len + 1);
      text_size = len + 1;
      hb_ot_name_get_utf8(*f, name_id, lang, &text_size, name);
      lua_pushstring(L, name);
      free(name);
    }
  } else {
    lua_pushnil(L);
  }

  return 1;
}

static int face_get_table(lua_State *L) {
  Face *f = (Face *)luaL_checkudata(L, 1, "harfbuzz.Face");
  Tag *t = (Tag *)luaL_checkudata(L, 2, "harfbuzz.Tag");
  Blob *b;

  b = (Blob *)lua_newuserdata(L, sizeof(*b));
  luaL_getmetatable(L, "harfbuzz.Blob");
  lua_setmetatable(L, -2);

  *b = hb_face_reference_table(*f, *t);

  return 1;
}

static int face_get_table_tags(lua_State *L) {
  Face *f = (Face *)luaL_checkudata(L, 1, "harfbuzz.Face");
  hb_tag_t tags[STATIC_ARRAY_SIZE];
  unsigned int count = STATIC_ARRAY_SIZE;

  if (hb_face_get_table_tags(*f, 0, NULL, NULL)) {
    unsigned int i = 0, offset = 0;
    lua_newtable(L);
    do {
      count = STATIC_ARRAY_SIZE;
      hb_face_get_table_tags(*f, offset, &count, tags);
      for (i = 0; i < count; i++) {
        lua_pushnumber(L, i + 1);

        Tag *tp = (Tag *)lua_newuserdata(L, sizeof(*tp));
        luaL_getmetatable(L, "harfbuzz.Tag");
        lua_setmetatable(L, -2);
        *tp = tags[i];

        lua_rawset(L, -3);
      }
      offset += count;
    } while (count == STATIC_ARRAY_SIZE);
  } else {
    lua_pushnil(L);
  }

  return 1;
}

static int face_collect_unicodes(lua_State *L) {
  Face *f = (Face *)luaL_checkudata(L, 1, "harfbuzz.Face");
  hb_set_t *codes = hb_set_create();

  lua_newtable(L);

  hb_face_collect_unicodes (*f, codes);
  if (!hb_set_is_empty(codes)) {
    unsigned int i = 0;
    hb_codepoint_t c = HB_SET_VALUE_INVALID;

    while (hb_set_next(codes, &c)) {
      lua_pushnumber(L, ++i);
      lua_pushnumber(L, c);
      lua_rawset(L, -3);
    }
  }

  hb_set_destroy(codes);

  return 1;
}

static int face_get_upem(lua_State *L) {
  Face *f = (Face *)luaL_checkudata(L, 1, "harfbuzz.Face");

  lua_pushinteger(L, hb_face_get_upem(*f));
  return 1;
}

static int face_ot_color_has_palettes(lua_State *L) {
  Face *f = (Face *)luaL_checkudata(L, 1, "harfbuzz.Face");

  lua_pushboolean(L, hb_ot_color_has_palettes(*f));
  return 1;
}

static int face_ot_color_palette_get_count(lua_State *L) {
  Face *f = (Face *)luaL_checkudata(L, 1, "harfbuzz.Face");

  lua_pushinteger(L, hb_ot_color_palette_get_count(*f));
  return 1;
}

static int face_ot_color_palette_get_colors(lua_State *L) {
  Face *f = (Face *)luaL_checkudata(L, 1, "harfbuzz.Face");
  unsigned int index = 0;

  if (lua_gettop(L) > 1)
    index = (unsigned int) luaL_checkinteger(L, 2) - 1;

  hb_color_t colors[STATIC_ARRAY_SIZE];
  unsigned int count = STATIC_ARRAY_SIZE;

  if (hb_ot_color_palette_get_colors(*f, index, 0, NULL, NULL)) {
    unsigned int i = 0, offset = 0;
    lua_newtable(L); // parent table
    do {
      count = STATIC_ARRAY_SIZE;
      hb_ot_color_palette_get_colors(*f, index, offset, &count, colors);
      for (i = 0; i < count; i++) {
        hb_color_t color = colors[i];

        lua_pushnumber(L, i+1); // 1-indexed key parent table
        lua_newtable(L);        // child table

        lua_pushinteger(L, hb_color_get_red(color));
        lua_setfield(L, -2, "red");

        lua_pushinteger(L, hb_color_get_green(color));
        lua_setfield(L, -2, "green");

        lua_pushinteger(L, hb_color_get_blue(color));
        lua_setfield(L, -2, "blue");

        lua_pushinteger(L, hb_color_get_alpha(color));
        lua_setfield(L, -2, "alpha");

        lua_settable(L, -3); // Add child table at index i+1 to parent table
      }
      offset += count;
    } while (count == STATIC_ARRAY_SIZE);
  } else {
    lua_pushnil(L);
  }

  return 1;
}

static int face_ot_color_has_layers(lua_State *L) {
  Face *f = (Face *)luaL_checkudata(L, 1, "harfbuzz.Face");

  lua_pushboolean(L, hb_ot_color_has_layers(*f));
  return 1;
}

static int face_ot_color_glyph_get_layers(lua_State *L) {
  Face *f = (Face *)luaL_checkudata(L, 1, "harfbuzz.Face");
  hb_codepoint_t gid = (hb_codepoint_t) luaL_checkinteger(L, 2);
  hb_ot_color_layer_t layers[STATIC_ARRAY_SIZE];
  unsigned int count = STATIC_ARRAY_SIZE;

  if (hb_ot_color_glyph_get_layers(*f, gid, 0, NULL, NULL)) {
    unsigned int i = 0, offset = 0;
    lua_newtable(L); // parent table
    do {
      count = STATIC_ARRAY_SIZE;
      hb_ot_color_glyph_get_layers(*f, gid, offset, &count, layers);
      for (i = 0; i < count; i++) {
        hb_ot_color_layer_t layer = layers[i];
        unsigned int color_index = layer.color_index;
        if (color_index != 0xFFFF)
          color_index++; // make it 1-indexed

        lua_pushnumber(L, i+1);  // 1-indexed key parent table
        lua_newtable(L);         // child table

        lua_pushinteger(L, layer.glyph);
        lua_setfield(L, -2, "glyph");

        lua_pushinteger(L, color_index);
        lua_setfield(L, -2, "color_index");

        lua_settable(L, -3); // Add child table at index i+1 to parent table
      }
      offset += count;
    } while (count == STATIC_ARRAY_SIZE);
  } else {
    lua_pushnil(L);
  }

  return 1;
}

static int face_destroy(lua_State *L) {
  Face *f = (Face *)luaL_checkudata(L, 1, "harfbuzz.Face");

  hb_face_destroy(*f);
  return 0;
}

static const struct luaL_Reg face_methods[] = {
  { "__gc", face_destroy },
  { "collect_unicodes", face_collect_unicodes },
  { "get_glyph_count", face_get_glyph_count },
  { "get_name", face_get_name },
  { "get_table", face_get_table },
  { "get_table_tags", face_get_table_tags },
  { "get_upem", face_get_upem },
  { "ot_color_has_palettes", face_ot_color_has_palettes },
  { "ot_color_palette_get_count", face_ot_color_palette_get_count },
  { "ot_color_palette_get_colors", face_ot_color_palette_get_colors },
  { "ot_color_has_layers", face_ot_color_has_layers },
  { "ot_color_glyph_get_layers", face_ot_color_glyph_get_layers },
  { NULL, NULL }
};

static const struct luaL_Reg face_functions[] = {
  { "new", face_new },
  { "new_from_blob", face_new_from_blob },
  { NULL,  NULL }
};

int register_face(lua_State *L) {
  return register_class(L, "harfbuzz.Face", face_methods, face_functions, NULL);
}
