-- Switch off some callbacks
callback.register("hyphenate", false)
callback.register("ligaturing", false)
callback.register("kerning", false)

-- Add debug statements to some callbacks
callback.register("post_linebreak_filter", function()
  texio.write_nl("POST_LINEBREAK")
  return true
end)

callback.register("hpack_filter", function()
  texio.write_nl("HPACK")
  return true
end)

callback.register("vpack_filter", function()
  texio.write_nl("VPACK")
  return true
end)

callback.register("buildpage_filter", function(extrainfo)
  texio.write_nl("BUILDPAGE_FILTER "..extrainfo)
end)
