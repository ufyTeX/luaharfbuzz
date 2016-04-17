## Using _luaharfbuzz_ with LuaTeX

This is proof of concept, incomplete code to use _luaharfbuzz_ to shape text in
the LuaTeX typesetting engine. The code can handle very simple paragraphs of
text, typeset in the same font and script. There are assertions throughout the
code which fail with an error, if the paragraph nodes do not conform to what the
code expects.

### Running the examples
The examples were tested with LuaTeX 1.0, inside a local [luatexminimal] texmf
tree.

[luatexminimal]:https://github.com/deepakjois/luatexminimal

Do not try to run the examples under TeXLive, unless you know what you
are doing.  TeXLive 2015 contains LuaTeX 0.80, which is too old. The
examples assume a very basic LuaTeX environment with only the plain
TeX format loaded. TeXLive formats for LuaTeX come with a lot more 
initialization code, which could interfere with the commands in the 
example files. Instead, it is recommended that you setup _luatexminimal_.

The examples can be run like:

```
luatex --fmt=plain doc.tex
```

If you encounter any issues, or have further questions, please [file an issue](https://github.com/deepakjois/luaharfbuzz/issues/new).

### Sample PDFs
Check the [Samples folder](./samples).
