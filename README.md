# Lua Harfbuzz bindings

Simple Lua binding to Harbuzz (WIP).

Documentation, packaging etc. will be added once the API has evolved a bit
more.

### How to use

Make sure you have Harfbuzz and
[penlight](https://luarocks.org/modules/steved/penlight) installed before
running `make test`. If everything works, you will see an out


```
$> make test

…<compilation output>…

lua harfbuzz_test.lua notonastaliq.ttf "یہ"
No. of glyphs   4
{
  {
    h = -1591,
    ax = 472,
    w = 711,
    yb = 1096,
    dy = 0,
    cl = 2,
    gid = 277,
    xb = 0,
    ay = 0,
    dx = 0
  },
  {
    h = -549,
    ax = 0,
    w = 659,
    yb = 0,
    dy = -383,
    cl = 0,
    gid = 19,
    xb = -328,
    ay = 0,
    dx = 310
  },
  {
    h = 0,
    ax = 0,
    w = 0,
    yb = 0,
    dy = 0,
    cl = 0,
    gid = 985,
    xb = 0,
    ay = 0,
    dx = 0
  },
  {
    h = -1566,
    ax = 731,
    w = 551,
    yb = 1049,
    dy = -68,
    cl = 0,
    gid = 316,
    xb = -67,
    ay = 0,
    dx = 0
  }
}
```

### Questions or comments

Open a Github issue, or email me at <deepak.jois@gmail.com>.
