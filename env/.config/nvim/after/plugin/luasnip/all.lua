local snippet, text = require("luasnip").s, require("luasnip").t

return {
  snippet(
    { trig = "hi" },
    { text("Hello, world!") }
  ),

  snippet(
    { trig = "foo" },
    { text("Another snippet.") }
  ),
}
