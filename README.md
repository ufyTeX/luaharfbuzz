# Lua Harfbuzz bindings

Lua bindings for [Harbuzz] (WIP).

[Harfbuzz]:http://harfbuzz.org

## Contents

* [Overview](#overview)
* [Installing Harfbuzz](#installing-harfbuzz)
* [Installing luaharfbuzz](#installing-luaharfbuzz)
* [Documentation and examples](#documentation-and-examples)
* [Building](#building)
* [Testing and Linting](#testing-and-linting)
* [Contact](#contact)

## Overview
HarfBuzz is an OpenType text shaping engine. It is used in software like Qt,
Pango, Firefox, Chromium, XeTeX and LibreOffice.

luaharfbuzz provides bindings for the most common types in Harfbuzz. The
initial motivation for building it is to use Harfbuzz with the [LuaTeX]
typesetting system. However, the codebase isn’t tied to LuaTeX in any way. It
can be used with any Lua code.

[LuaTeX]:luatex.org

## Installing Harfbuzz

Make sure you have [Harfbuzz] libraries and headers installed on your system.

#### OS X

```
brew install harfbuzz
```

#### Other Platforms
_Send a pull request if you want to include specific instructions to install
Harfbuzz on your preferred platform._

Before building, the Makefile looks for Harfbuzz headers and libraries using `pkg-config`. If your system returns a value for the following commands, then you should be able to install luaharfbuzz on it by following instructions in the next section.

```
pkg-config --cflags harfbuzz lua
pkg-config --libs harfbuzz
```

## Installing luaharfbuzz

#### Luarocks
_The package hasn’t been submitted for inclusion in the rocks server yet_

If you have [Luarocks] installed, you can install the package like:

```
luarocks make
```

[Luarocks]: https://luarocks.org

#### Directly Using Makefile
See [Building](#building)

## Documentation and Examples

_COMING SOON_

## Building
It is possible to build a copy of luaharfbuzz using the Makefile provided in the distribution. Running `make` will build a copy of the library `luaharfbuzz.so` in the root folder of the repo. You can then copy the .so file into your `package.cpath` and copy `src/harfbuzz.lua` into `package.path` folder.

## Testing and Linting
In order to make changes to the code and run the tests, you will need to install the following dependencies:

```
lua install busted
lua install luacheck
```

After that, you can run the tests
```
make spec
```

or lint the code
```
make lint
```

## Contact
Open a Github issue, or email me at <deepak.jois@gmail.com>.
