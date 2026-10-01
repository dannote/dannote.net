defmodule Blog.LinkPreview do
  @moduledoc """
  Link previews for URLs posted in notes, fetched once at build time.

  Like the cards X renders for a posted link: title, description, favicon, and
  social image. Metadata lives in `content/link_previews.json` and images under
  `assets/images/links/`, both committed, so builds are reproducible offline. A
  URL is fetched only when it is missing from the cache; a failed fetch is not
  cached, so the next build retries it.
  """

  defmodule Preview do
    @moduledoc "What a card shows for one URL. Image paths are relative to the image source directories."
    use JSONCodec, strict: true

    defstruct [:host, :title, :description, :image, :icon]

    @type t :: %__MODULE__{
            host: String.t(),
            title: String.t() | nil,
            description: String.t() | nil,
            image: String.t() | nil,
            icon: String.t() | nil
          }
  end

  defmodule Cache do
    @moduledoc "The committed cache file: previews keyed by the URL as written in the note."
    use JSONCodec, strict: true

    defstruct entries: %{}

    @type t :: %__MODULE__{entries: %{String.t() => Preview.t()}}
  end

  @cache_file "content/link_previews.json"
  @image_dir "assets/images/links"
  @extensions %{
    "image/png" => ".png",
    "image/jpeg" => ".jpg",
    "image/webp" => ".webp",
    "image/svg+xml" => ".svg"
  }
  @user_agent "Mozilla/5.0 (compatible; dannote.net link previews)"

  @doc "Return the cached preview for a URL, fetching and caching it on first use."
  @spec get(String.t()) :: Preview.t()
  def get(url) when is_binary(url) do
    :global.trans({__MODULE__, :cache}, fn ->
      cache = read_cache()

      case Map.fetch(cache.entries, url) do
        {:ok, preview} -> preview
        :error -> fetch_and_cache(url, cache)
      end
    end)
  end

  defp fetch_and_cache(url, cache) do
    case fetch(url) do
      {:ok, preview} ->
        write_cache(%{cache | entries: Map.put(cache.entries, url, preview)})
        preview

      :error ->
        %Preview{host: host(url)}
    end
  end

  defp fetch(url) do
    with {:ok, %{status: status, body: body}} when status in 200..299 and is_binary(body) <-
           request(url),
         {:ok, document} <- Floki.parse_document(body) do
      {:ok,
       %Preview{
         host: host(url),
         title: meta(document, ["og:title", "twitter:title"]) || title_tag(document),
         description: meta(document, ["og:description", "twitter:description", "description"]),
         image: meta(document, ["og:image", "twitter:image"]) |> download(url, "image"),
         icon: icon_href(document) |> download(url, "icon")
       }}
    else
      _ -> :error
    end
  end

  defp request(url) do
    Req.get(url,
      headers: [user_agent: @user_agent],
      redirect: true,
      retry: false,
      receive_timeout: 10_000,
      decode_body: false
    )
  end

  defp meta(document, names) do
    Enum.find_value(names, fn name ->
      document
      |> Floki.find(~s(meta[property="#{name}"], meta[name="#{name}"]))
      |> Floki.attribute("content")
      |> List.first()
      |> presence()
    end)
  end

  defp title_tag(document) do
    document |> Floki.find("title") |> Floki.text() |> presence()
  end

  # Prefer the Apple touch icon: it is almost always a generous PNG.
  defp icon_href(document) do
    [
      ~s(link[rel="apple-touch-icon"]),
      ~s(link[rel="apple-touch-icon-precomposed"]),
      ~s(link[rel~="icon"])
    ]
    |> Enum.find_value(fn selector ->
      document |> Floki.find(selector) |> Floki.attribute("href") |> List.first() |> presence()
    end)
  end

  defp presence(nil), do: nil

  defp presence(value) do
    case String.trim(value) do
      "" -> nil
      trimmed -> trimmed
    end
  end

  # Downloads a raster image next to the other note images and returns its
  # source path for `<.image>`, or nil when there is nothing usable.
  defp download(nil, _page_url, _kind), do: nil

  defp download(href, page_url, kind) do
    url = page_url |> URI.merge(href) |> URI.to_string()

    with {:ok, %{status: status, body: body, headers: headers}} when status in 200..299 <-
           request(url),
         {:ok, extension} <- extension(headers, url) do
      name = "#{slug(page_url)}-#{kind}#{extension}"
      File.mkdir_p!(@image_dir)
      path = Path.join(@image_dir, name)
      File.write!(path, body)
      Path.join("images/links", shrink(path, kind))
    else
      _ -> nil
    end
  end

  # Social images arrive at 1200px or more; the card shows them at 128px. Store a
  # WebP no wider than @max_width so the committed file stays small. Icons and SVGs
  # are already small and are kept as they are.
  @max_width 640

  defp shrink(path, "image") do
    if Path.extname(path) == ".svg" do
      Path.basename(path)
    else
      webp = Path.rootname(path) <> ".webp"

      path
      |> Image.open!()
      |> Image.thumbnail!(@max_width, resize: :down)
      |> Image.write!(webp, quality: 80)

      if webp != path, do: File.rm!(path)
      Path.basename(webp)
    end
  end

  defp shrink(path, _kind), do: Path.basename(path)

  defp extension(headers, url) do
    content_type =
      headers
      |> Map.get("content-type", [])
      |> List.first("")
      |> String.split(";", parts: 2)
      |> hd()
      |> String.downcase()

    cond do
      Map.has_key?(@extensions, content_type) ->
        {:ok, @extensions[content_type]}

      Path.extname(URI.parse(url).path || "") in Map.values(@extensions) ->
        {:ok, Path.extname(URI.parse(url).path)}

      true ->
        :error
    end
  end

  defp slug(url) do
    uri = URI.parse(url)
    base = String.replace(uri.host <> (uri.path || ""), ~r/[^a-z0-9]+/i, "-") |> String.trim("-")
    hash = :crypto.hash(:sha256, url) |> Base.encode16(case: :lower) |> binary_part(0, 8)
    "#{String.slice(base, 0, 60)}-#{hash}" |> String.downcase()
  end

  defp host(url),
    do: url |> URI.parse() |> Map.get(:host, "") |> String.replace_prefix("www.", "")

  defp read_cache do
    case File.read(@cache_file) do
      {:ok, json} -> Cache.decode!(json)
      {:error, :enoent} -> %Cache{}
    end
  end

  defp write_cache(%Cache{} = cache) do
    File.write!(@cache_file, Jason.encode!(JSONCodec.dump(cache), pretty: true) <> "\n")
  end
end
