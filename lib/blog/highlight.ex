defmodule Blog.Highlight do
  @moduledoc """
  Code the site marks up by hand, rendered to look like Lumis output.

  Lumis highlights fenced code at build time with the GitHub light and dark themes.
  A few illustrations need markup no grammar produces: a language Lumis has no parser
  for, or coloring by role rather than by syntax. Those blocks are written as data,
  lines of `{token, text}` segments, and rendered here with the same colors, so they
  look like every other block in both themes and no template formatter can reflow them.
  """

  import Phoenix.HTML, only: [html_escape: 1, raw: 1, safe_to_string: 1]

  @tokens %{
    keyword: {"#cf222e", "#ff7b72"},
    function: {"#6639ba", "#d2a8ff"},
    type: {"#953800", "#ffa657"},
    operator: {"#0550ae", "#79c0ff"},
    string: {"#0a3069", "#a5d6ff"},
    comment: {"#57606a", "#8b949e"},
    added: {"#116329", "#7ee787"},
    removed: {"#cf222e", "#ff7b72"}
  }

  @type token :: :keyword | :function | :type | :operator | :string | :comment | :added | :removed
  @type segment :: String.t() | {token(), String.t()}
  @type line :: [segment()]

  @doc "Render lines of segments as the spans Lumis would emit; plain strings stay uncolored."
  @spec render([line()]) :: Phoenix.HTML.safe()
  def render(lines) do
    lines
    |> Enum.map_join("\n", fn line -> Enum.map_join(line, &segment/1) end)
    |> raw()
  end

  defp segment(text) when is_binary(text), do: escape(text)

  defp segment({token, text}),
    do: ~s(<span style="#{style(token)}">#{escape(text)}</span>)

  defp escape(text), do: text |> html_escape() |> safe_to_string()

  @doc "Inline style for a token, as Lumis emits it: one color per theme."
  @spec style(token()) :: String.t()
  def style(token) do
    {light, dark} = Map.fetch!(@tokens, token)
    "color: light-dark(#{light}, #{dark});"
  end

  @doc "Inline style for the block itself, matching Lumis's `<pre>`."
  @spec pane_style() :: String.t()
  def pane_style,
    do: "color: light-dark(#1f2328, #e6edf3); background-color: light-dark(#ffffff, #0d1117);"

  @doc "Classes Lumis puts on its `<pre>`, so the site's theme rules apply."
  @spec pane_class() :: String.t()
  def pane_class, do: "lumis lumis-themes dark light"
end
