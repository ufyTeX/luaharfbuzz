# _luaharfbuzz_

Lua bindings for [Harbuzz] (WIP).

[Harfbuzz]:http://harfbuzz.org

## Contents

* [Overview](#overview)
* [Installing Harfbuzz](#installing-harfbuzz)
* [Installing _luaharfbuzz_](#installing-luaharfbuzz)
* [Documentation and examples](#documentation-and-examples)
* [Building](#building)
* [Testing and Linting](#testing-and-linting)
* [Contact](#contact)

## Overview
HarfBuzz is an OpenType text shaping engine. It is used in software like Qt,
Pango, Firefox, Chromium, XeTeX and LibreOffice.

_luaharfbuzz_ provides bindings for the most common types in Harfbuzz. The
initial motivation for building it is to use Harfbuzz with the [LuaTeX]
typesetting system. However, the module isn’t tied to LuaTeX in any way. It
can be used with any Lua codebase.

[LuaTeX]:luatex.org

## Installing Harfbuzz

Make sure [Harfbuzz] libraries and headers are installed.

#### OS X

Install via [Homebrew](http://brew.sh/)

```
brew install harfbuzz
```

#### Other Platforms
_Send a pull request if you want to include specific instructions to install
Harfbuzz on your preferred platform._

Before building, the Makefile looks for Harfbuzz headers and libraries using `pkg-config`. If the following commands run without errors, then it should be possible to install _luaharfbuzz_ on it by following instructions given in the next section.

```
pkg-config --cflags harfbuzz lua
pkg-config --libs harfbuzz
```

## Installing _luaharfbuzz_

#### Luarocks
_The package hasn’t been submitted for inclusion in the rocks server yet_

If [Luarocks] is installed, _luaharfbuzz_ can be installed like this:

```
luarocks make
```

[Luarocks]: https://luarocks.org

#### Directly Using Makefile
See [Building](#building)

## Documentation and Examples

_COMING SOON_

## Building
It is possible to build a copy of _luaharfbuzz_ using the Makefile provided in the distribution. Running `make` will build a copy of the library `luaharfbuzz.so` in the root directory of the repo. The Lua source files are located under the `src` directory.

## Testing and Linting
In order to make changes to the code and run the tests, the following dependencies need to be installed:

* [Busted](http://olivinelabs.com/busted/) – `luarocks install busted`
* [luacheck](luacheck.readthedocs.org) – `luarocks install luacheck`

Run the test suite:
```
make spec
```

Lint the codebase:
```
make lint
```

## Contact
Open a Github issue, or email me at <deepak.jois@gmail.com>.
