#include "luaharfbuzz.h"

static int face_new(lua_State *L) {
  Face *f;
  hb_blob_t *blob;
  unsigned int font_index = 0;
  const char *file_name = luaL_checkstring(L, 1);

  if (lua_gettop(L) > 1)
    font_index = (unsigned int) luaL_checkinteger(L, 2);

  blob = hb_blob_create_from_file(file_name);

  f = (Face *)lua_newuserdata(L, sizeof(*f));
  luaL_getmetatable(L, "harfbuzz.Face");
  lua_setmetatable(L, -2);

  *f = hb_face_create(blob, font_index);
  return 1;
}

static int face_new_from_blob(lua_State *L) {
  Face *f;
  Blob *blob = luaL_checkudata(L, 1, "harfbuzz.Blob");
  unsigned int font_index = (unsigned int) luaL_checkinteger(L, 2);

  f = (Face *)lua_newuserdata(L, sizeof(*f));
  luaL_getmetatable(L, "harfbuzz.Face");
  lua_setmetatable(L, -2);

  *f = hb_face_create(*blob, font_index);
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
#define TEXT_SIZE 128
  int text_size = TEXT_SIZE, len;
  char name[TEXT_SIZE];

  if (lua_gettop(L) > 2)
    lang = *((Language*)luaL_checkudata(L, 3, "harfbuzz.Language"));

  len = hb_ot_name_get_utf8(*f, name_id, lang, &text_size, name);
  if (len) {
    if (len < TEXT_SIZE) {
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
#undef TEXT_SIZE

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

static void set_tags(lua_State *L, hb_tag_t *tags, unsigned int count) {
  unsigned int i;

  for (i = 0; i < count; i++) {
    lua_pushnumber(L, i + 1);

    Tag *tp = (Tag *)lua_newuserdata(L, sizeof(*tp));
    luaL_getmetatable(L, "harfbuzz.Tag");
    lua_setmetatable(L, -2);
    *tp = tags[i];

    lua_rawset(L, -3);
  }
}

static int face_get_table_tags(lua_State *L) {
  Face *f = (Face *)luaL_checkudata(L, 1, "harfbuzz.Face");
#define TABLE_SIZE 128
  unsigned int table_size = TABLE_SIZE, count;
  hb_tag_t tags[TABLE_SIZE];

  lua_newtable(L);

  count = hb_face_get_table_tags(*f, 0, &table_size, tags);
  if (count) {
    if (count <= table_size) {
      set_tags(L, tags, count);
    } else {
      hb_tag_t* tags = (hb_tag_t *) malloc(count * sizeof(hb_tag_t));
      hb_face_get_table_tags (*f, 0, &count, tags);
      set_tags(L, tags, count);
      free(tags);
    }
  }
#undef TABLE_SIZE

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
