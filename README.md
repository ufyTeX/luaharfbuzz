# _luaharfbuzz_

Lua bindings for [Harbuzz] (WIP).

[Harfbuzz]:http://harfbuzz.org

## Contents

* [Overview](#overview)
* [Installing Harfbuzz](#installing-harfbuzz)
* [Installing _luaharfbuzz_](#installing-luaharfbuzz)
* [Sample Code](#sample-code)
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

## Sample Code

Here is some sample code, showcasing the core types and methods in the API.

```lua
local harfbuzz = require('harfbuzz')
local pl = require('pl.pretty') -- luarocks install penlight

-- Harfbuzz API Version
print("Harfbuzz API version", harfbuzz.version())

-- Shapers available
print("Shapers:")
pl.dump({ harfbuzz.shapers() })

-- harfbuzz.Face
local face = harfbuzz.Face.new('fonts/notonastaliq.ttf')
print('Face upem = '..face:get_upem())

-- harfbuzz.Font
local font = harfbuzz.Font.new(face)
local xs, xy = font:get_scale()
print("Default font scale = X: "..xs..", Y: "..xy)

-- harfbuzz.Buffer
local text = "یہ" -- U+06CC U+06C1
local buf = harfbuzz.Buffer.new()
buf:add_utf8(text)
buf:guess_segment_properties()

-- harfbuzz.shape (Shapes text)
print("Shaping '"..text.."' set with Noto Nastaliq Urdu")
local glyphs = { harfbuzz.shape(font, buf) }

print("No. of glyphs", #glyphs)
pl.dump(glyphs)

```

## Documentation and Examples

_COMING SOON_ (Tasks being tracked in [#10] and [#11], so any help is appreciated)

[#10]: https://github.com/deepakjois/luaharfbuzz/issues/10
[#11]: https://github.com/deepakjois/luaharfbuzz/issues/11

Meanwhile, take a look at:

* The sample code posted above.
* The [specs], which contain a comprehensive overview of the methods and types that have been wrapped so far.
* Michal Hoftich’s (highly) experimental code [integrating luaharfbuzz with LuaTeX][lua-harfbuzz-luatex].

[specs]:https://github.com/deepakjois/luaharfbuzz/tree/master/spec
[lua-harfbuzz-luatex]:(https://github.com/michal-h21/luaharfbuzz-luatex-test)

## Building
It is possible to build _luaharfbuzz_ using the Makefile provided in the distribution. Running `make` will build the library `luaharfbuzz.so` in the root directory of the repo. The Lua source files are located under the `src` directory. To use them with Lua, you will need to update your `package.path` and `package.cpath` approrpiately.

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
