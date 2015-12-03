# Guide to building Lua Modules: http://lua-users.org/wiki/BuildingModules

PKGS = harfbuzz

CFLAGS = -O2 -fpic -std=c99 `pkg-config --cflags $(PKGS)` `pkg-config --cflags lua`
LDFLAGS = -O2 -fpic `pkg-config --libs $(PKGS)`

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    LIBFLAGS = -shared
endif
ifeq ($(UNAME_S),Darwin)
    LIBFLAGS = -bundle -undefined dynamic_lookup -all_load
endif

.PHONY: all clean test luarocks

all: luaharfbuzz.so

src/luaharfbuzz/luaharfbuzz.o: src/luaharfbuzz/luaharfbuzz.c
	$(CC) $(CFLAGS) -o $@ -c $<

luaharfbuzz.so: src/luaharfbuzz/luaharfbuzz.o
	$(CC) $(LDFLAGS) $(LIBFLAGS) $<  -o $@

test: all
	lua test/harfbuzz_test.lua fonts/notonastaliq.ttf "یہ"

clean:
	rm -f src/luaharfbuzz/*.o *.so
