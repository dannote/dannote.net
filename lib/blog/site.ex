defmodule Blog.Site do
  @moduledoc "Shared identity for page metadata, feeds, and social cards."

  @doc "The site's author and display name."
  @spec author() :: String.t()
  def author, do: "Danila Poyarkov"

  @doc "The public domain, used as a short display label."
  @spec domain() :: String.t()
  def domain, do: "dannote.net"

  @doc "The public contact address."
  @spec email() :: String.t()
  def email, do: "hello@" <> domain()

  @doc "The canonical site origin."
  @spec url() :: String.t()
  def url, do: "https://" <> domain()

  @doc "Resolve a site path against the canonical origin."
  @spec absolute_url(String.t()) :: String.t()
  def absolute_url(path), do: url() |> URI.merge(path) |> URI.to_string()

  @doc "The default description for the site and its social card."
  @spec description() :: String.t()
  def description do
    "Open-source tools for coding agents, design automation, and the Elixir ecosystem."
  end

  @doc "The title used by feed metadata and discovery links."
  @spec feed_title() :: String.t()
  def feed_title, do: author() <> " — Writing"
end
