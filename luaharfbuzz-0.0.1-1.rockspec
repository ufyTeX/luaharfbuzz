package = "luaharfbuzz"
version = "0.0.1-1"
source = {
  url = "https://github.com/luaharfbuzz",
  tag = "master"
}
description = {
  summary = "Lua bindings for the Harfbuzz text shaping library",
  homepage = "https://github.com/luaharfbuzz",
  license = "MIT",
  maintainer = "Deepak Jois <deepak.jois@gmail.com>"
}
dependencies = {
  "lua ~> 5.2"
}
external_dependencies = {
  HARFBUZZ = { header = "harfbuzz/hb-ot.h", library = "harfbuzz" }
}
build = {
  type = "make",
  install_variables = {
    INST_LIBDIR="$(LIBDIR)",
    INST_LUADIR="$(LUADIR)",
  },
}
