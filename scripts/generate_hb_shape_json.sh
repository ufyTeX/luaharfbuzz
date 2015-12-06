#!/bin/sh

STANDARD_OPTS="--font-funcs=ot --utf8-clusters --no-glyph-names --shapers=ot --output-format=json"

hb-shape $STANDARD_OPTS fonts/notonastaliq.ttf "یہ" > fixtures/notonastaliq_U06CC_U06C1.json
hb-shape $STANDARD_OPTS fonts/amiri-regular.ttf "123" > fixtures/amiri-regular_123.json
hb-shape $STANDARD_OPTS --features="+numr" fonts/amiri-regular.ttf "123" > fixtures/amiri-regular_123_numr.json
