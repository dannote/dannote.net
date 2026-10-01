defmodule Blog.SocialImages do
  @moduledoc """
  Blog-owned social cards rendered by Skia through Astral's generated routes.

  Fonts are bundled so builds do not depend on installed fonts or remote services.
  The default card represents ordinary pages; published articles get their own card.

  The site is set in Helvetica Neue, which the cards can't use: CI renders them on Linux,
  which doesn't have it, and its license doesn't cover it anyway. Cards are drawn in
  TeX Gyre Heros instead, a free digitization of Helvetica, so a card looks like the
  page it links to. At 1200 × 630 its weaker screen hinting doesn't show. It has no
  Cyrillic, so any text containing Cyrillic is drawn in Inter, the site's web fallback.
  Both live in `priv/fonts/` with their licenses.
  """

  @behaviour Astral.Plugin

  import Skia, only: [canvas: 2, clear: 2, rect: 2, text: 3, to_png: 1]
  alias Astral.{Collection, Route}
  alias Blog.Site
  alias Skia.{Font, Typeface}

  @site_card %{
    title: Site.author(),
    description: Site.description(),
    domain: Site.domain()
  }
  @palette %{
    paper: "#f4f1e9",
    ink: "#15161a",
    muted: "#555961",
    accent: "#b43325",
    rule: "#bcbab4"
  }
  @width 1200
  @height 630
  @inset 64
  @content_width @width - 2 * @inset
  @marker %{y: @inset, width: 56, height: 6}
  @title %{top: 108, height: 280, size: 76, line_height: 90, max_lines: 3}
  @description %{top: 404, height: 90, size: 34, line_height: 44, max_lines: 2}
  @footer %{rule_y: 532, rule_height: 1, baseline: 580, size: 30}
  @ellipsis "…"

  @doc "Identify this site-local plugin."
  @impl true
  @spec name() :: String.t()
  def name, do: "blog:social-images"

  @doc "Return the generated image path for an article, or the default site card."
  @spec path(String.t() | nil) :: String.t()
  def path(route \\ nil)
  def path(nil), do: "/social/site.png"
  def path(route), do: "/social" <> String.trim_trailing(route, "/") <> ".png"

  @doc "Register the default card and cards for published articles."
  @impl true
  @spec routes(Astral.Site.t(), keyword()) :: [Route.t()]
  def routes(site, _opts) do
    default = card_route(site, path(), @site_card)

    articles =
      site
      |> Collection.entries(:articles)
      |> Collection.published()
      |> Enum.map(fn entry ->
        card_route(site, path(entry.route_path), %{
          title: entry.data.title,
          description: entry.data.description
        })
      end)

    [default | articles]
  end

  @doc "Render generated PNG routes identically in development and static builds."
  @impl true
  @spec render_route(Route.t(), Astral.Site.t(), keyword()) ::
          {:ok, binary(), String.t()} | {:error, term()} | nil
  def render_route(%Route{kind: :social_image, assigns: data}, _site, _opts) do
    with {:ok, png} <- render(data.title, data.description) do
      {:ok, png, "image/png"}
    end
  end

  def render_route(_route, _site, _opts), do: nil

  @doc "Draw a 1200 × 630 card, bounding long text with paragraph layout and ellipsis."
  @spec render(String.t(), String.t()) :: {:ok, binary()} | {:error, term()}
  def render(title, description) do
    with {:ok, faces} <- typefaces() do
      canvas(@width, @height)
      |> clear(@palette.paper)
      |> rect(
        x: @inset,
        y: @marker.y,
        width: @marker.width,
        height: @marker.height,
        fill: @palette.accent
      )
      |> paragraph(title, face(faces, title, :bold), @title, @palette.ink)
      |> paragraph(description, face(faces, description, :regular), @description, @palette.muted)
      |> rect(
        x: @inset,
        y: @footer.rule_y,
        width: @content_width,
        height: @footer.rule_height,
        fill: @palette.rule
      )
      |> text(@site_card.title,
        x: @inset,
        y: @footer.baseline,
        font: Font.new(face(faces, @site_card.title, :regular)),
        size: @footer.size,
        fill: @palette.ink
      )
      |> text(@site_card.domain,
        x: right_aligned(@site_card.domain, face(faces, @site_card.domain, :bold), @footer.size),
        y: @footer.baseline,
        font: Font.new(face(faces, @site_card.domain, :bold)),
        size: @footer.size,
        fill: @palette.accent
      )
      |> to_png()
    end
  end

  defp paragraph(document, content, face, box, color) do
    text(document, content,
      x: @inset,
      y: box.top,
      width: @content_width,
      height: box.height,
      font: Font.new(face),
      size: box.size,
      fill: color,
      max_lines: box.max_lines,
      ellipsis: @ellipsis,
      line_height: box.line_height
    )
  end

  @fonts %{
    {:latin, :regular} => "TeXGyreHeros-Regular.otf",
    {:latin, :bold} => "TeXGyreHeros-Bold.otf",
    {:cyrillic, :regular} => "Inter-Regular.ttf",
    {:cyrillic, :bold} => "Inter-Bold.ttf"
  }

  defp typefaces do
    Enum.reduce_while(@fonts, {:ok, %{}}, fn {key, file}, {:ok, faces} ->
      case :blog |> Application.app_dir("priv/fonts/#{file}") |> Typeface.load_path() do
        {:ok, face} -> {:cont, {:ok, Map.put(faces, key, face)}}
        error -> {:halt, error}
      end
    end)
  end

  # The domain ends at the rule's right edge whatever the font's widths are.
  defp right_aligned(text, face, size) do
    {:ok, %{width: width}} = Skia.measure_text(text, font: Font.new(face), size: size)
    @inset + @content_width - width
  end

  # One string, one face: TeX Gyre Heros unless the text needs Cyrillic, which it lacks.
  defp face(faces, text, weight) do
    script = if String.match?(text, ~r/\p{Cyrillic}/u), do: :cyrillic, else: :latin
    Map.fetch!(faces, {script, weight})
  end

  defp card_route(site, path, card) do
    Route.new(path, site.config,
      kind: :social_image,
      content_type: "image/png",
      assigns: card
    )
  end
end
