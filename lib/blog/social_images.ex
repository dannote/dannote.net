defmodule Blog.SocialImages do
  @moduledoc """
  Blog-owned social cards rendered by Skia through Astral's generated routes.

  Fonts are bundled so builds do not depend on installed fonts or remote services.
  The default card represents ordinary pages; published articles get their own card.
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
  @footer %{rule_y: 532, rule_height: 1, baseline: 580, domain_x: 874, size: 30}
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
    with {:ok, regular} <- typeface("Regular"),
         {:ok, bold} <- typeface("Bold") do
      canvas(@width, @height)
      |> clear(@palette.paper)
      |> rect(
        x: @inset,
        y: @marker.y,
        width: @marker.width,
        height: @marker.height,
        fill: @palette.accent
      )
      |> paragraph(title, bold, @title, @palette.ink)
      |> paragraph(description, regular, @description, @palette.muted)
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
        font: Font.new(regular),
        size: @footer.size,
        fill: @palette.ink
      )
      |> text(@site_card.domain,
        x: @footer.domain_x,
        y: @footer.baseline,
        font: Font.new(bold),
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

  defp typeface(weight) do
    :blog |> Application.app_dir("priv/fonts/NotoSans-#{weight}.ttf") |> Typeface.load_path()
  end

  defp card_route(site, path, card) do
    Route.new(path, site.config,
      kind: :social_image,
      content_type: "image/png",
      assigns: card
    )
  end
end
