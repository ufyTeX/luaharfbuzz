#!/bin/sh

hb-shape               \
  --font-funcs=ot      \
  --no-glyph-names     \
  --shapers=ot         \
  --utf8-clusters      \
  --output-format=json \
  fonts/notonastaliq.ttf "یہ" > fixtures/notonastaliq_U06CC_U06C1.json
