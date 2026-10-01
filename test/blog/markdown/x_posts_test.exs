defmodule Blog.Markdown.XPostsTest do
  use ExUnit.Case, async: true

  defp render(markdown), do: MDEx.to_html!(markdown, plugins: [Blog.Markdown.XPosts])

  test "marks a quote that ends with a link to an X post" do
    html =
      render("""
      > New capabilities coming to Figma Make
      >
      > — Figma (@figma), [28 May 2026](https://x.com/figma/status/2060099693464478054)
      """)

    assert html =~ ~r{^<div class="x-post">\s*<blockquote>}
  end

  test "leaves other quotes alone" do
    refute render("> A quote.") =~ "x-post"
    refute render("> Ends with [a link](https://example.com).") =~ "x-post"
    refute render("> [A post](https://x.com/figma/status/1) and more text.") =~ "x-post"
  end

  test "marks only the nested quote that is the post" do
    html =
      render("""
      > Someone forwarded this:
      >
      > > today in MCP land ...
      > >
      > > — Mario Zechner (@badlogicgames), [30 Sep 2026](https://x.com/badlogicgames/status/2105234146499203255)
      """)

    assert html =~ ~r{^<blockquote>\s*<p>Someone forwarded this:</p>\s*<div class="x-post">}
    assert [_marked] = Regex.scan(~r/class="x-post"/, html)
  end
end
