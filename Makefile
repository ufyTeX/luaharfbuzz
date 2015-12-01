# Guide to building Lua Modules: http://lua-users.org/wiki/BuildingModules

PKGS = harfbuzz

CFLAGS = -O2 -fpic -std=c99 `pkg-config --cflags $(PKGS)` `pkg-config --cflags lua`
LDFLAGS = -O2 -fpic `pkg-config --libs $(PKGS)`

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    LIBFLAGS = -shared
endif
ifeq ($(UNAME_S),Darwin)
    LIBFLAGS = -dynamiclib -undefined dynamic_lookup
endif

.PHONY: all clean test

all: luaharfbuzz.so

luaharfbuzz.o: luaharfbuzz.c
	$(CC) $(CFLAGS) -c luaharfbuzz.c

luaharfbuzz.so: luaharfbuzz.o
	$(CC) $(LDFLAGS) $(LIBFLAGS) -o luaharfbuzz.so luaharfbuzz.o

test: all
	lua test/harfbuzz_test.lua fonts/notonastaliq.ttf "یہ"

clean:
	rm -f *.o *.so

