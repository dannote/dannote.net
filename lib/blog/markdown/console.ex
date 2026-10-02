defmodule Blog.Markdown.Console do
  @moduledoc """
  An MDEx plugin that colors terminal sessions by role.

  A `console` fence is a session: lines that start with `$ ` are commands, the rest is
  their output. A shell grammar would color words in the output as if they were code,
  so the block is drawn through `Blog.Highlight` instead, with the prompt in grey,
  `file:line` locations in blue, and Mix's `** ` failure lines in red.
  """

  import Phoenix.HTML, only: [safe_to_string: 1]

  alias Blog.Highlight
  alias MDEx.Document

  @location ~r{[\w./-]+\.exs?:\d+}

  @doc "Attaches the plugin to an MDEx document."
  @spec attach(Document.t(), keyword()) :: Document.t()
  def attach(document, _options \\ []) do
    Document.append_steps(document, color_console: &color_console/1)
  end

  defp color_console(document) do
    Document.update_nodes(document, MDEx.CodeBlock, fn
      %MDEx.CodeBlock{info: "console", literal: literal} ->
        %MDEx.HtmlBlock{literal: pane(literal)}

      block ->
        block
    end)
  end

  defp pane(literal) do
    lines = literal |> String.trim_trailing("\n") |> String.split("\n") |> Enum.map(&line/1)
    code = lines |> Highlight.render() |> safe_to_string()

    ~s(<pre class="#{Highlight.pane_class()}" style="#{Highlight.pane_style()}">) <>
      ~s(<code class="language-console" translate="no" tabindex="0">#{code}</code></pre>\n)
  end

  defp line("$ " <> command), do: [{:comment, "$ "}, command]
  defp line("** " <> _rest = failure), do: [{:removed, failure}]

  defp line(output) do
    @location
    |> Regex.split(output, include_captures: true, trim: true)
    |> Enum.map(fn part -> if location?(part), do: {:operator, part}, else: part end)
  end

  defp location?(part), do: Regex.match?(@location, part) and Regex.run(@location, part) == [part]
end
