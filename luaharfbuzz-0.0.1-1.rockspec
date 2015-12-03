package = "luaharfbuzz"
version = "0.0.1-1"
source = {
   url = "https://github.com/luaharfbuzz",
   tag = "harfbuzz"
}
description = {
   summary = "Lua bindings for the Harfbuzz text shaping library",
   detailed = [[
      HarfBuzz is an OpenType text shaping engine. It is used
      in software like Qt, Pango, Firefox, Chromium, XeTeX
      and LibreOffice.

      luaharfbuzz provides bindings for the most common types
      in Harfbuzz. The initial motivation for building it is to
      use Harfbuzz with the LuaTeX typesetting system. However,
      it can be used with any Lua code.
   ]],
   homepage = "https://github.com/luaharfbuzz",
   license = "MIT"
}
dependencies = {
   "lua ~> 5.2"
}
external_dependencies = {
   HARFBUZZ = {
      library = "harfbuzz"
   }
}
build = {
   type = "builtin",
   modules = {
      luaharfbuzz = {
        sources = { "src/luaharfbuzz/luaharfbuzz.c" }
      }

   },
   copy_directories = {"spec"}
}
