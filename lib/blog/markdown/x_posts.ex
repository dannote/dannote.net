defmodule Blog.Markdown.XPosts do
  @moduledoc """
  An MDEx plugin that marks quoted X posts.

  A blockquote is an X post when its own last paragraph ends with a link to the post:

      > New capabilities coming to Figma Make
      >
      > — Figma (@figma), [28 May 2026](https://x.com/figma/status/2060099693464478054)

  The plugin wraps such a quote in `<div class="x-post">`. `assets/x-posts.ts` embeds
  the post there, and the quote stays as the fallback. Other blockquotes, including
  ones that hold an X post, are left as they are.
  """

  alias MDEx.Document

  @status_url ~r{^https://(?:x|twitter)\.com/\w+/status/\d+}

  @doc "Attaches the plugin to an MDEx document."
  @spec attach(Document.t(), keyword()) :: Document.t()
  def attach(document, _options \\ []) do
    Document.append_steps(document, mark_x_posts: &mark_x_posts/1)
  end

  defp mark_x_posts(document) do
    Document.update_nodes(document, MDEx.BlockQuote, fn quote ->
      if x_post?(quote), do: %MDEx.BlockDirective{info: "x-post", nodes: [quote]}, else: quote
    end)
  end

  defp x_post?(%MDEx.BlockQuote{nodes: nodes}) do
    with %MDEx.Paragraph{nodes: inlines} <- List.last(nodes),
         %MDEx.Link{url: url} <- List.last(inlines) do
      Regex.match?(@status_url, url)
    else
      _other -> false
    end
  end
end
