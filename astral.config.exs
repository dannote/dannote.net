import Astral.Config

root "."
outdir "dist"

plugin Astral.Plugin.Feed,
  site_url: "https://dannote.net",
  title: "Danila Poyarkov — Writing",
  author: "Danila Poyarkov",
  collection: :articles

plugin Astral.Plugin.Sitemap, site_url: "https://dannote.net"

layouts do
  default "site.astral"
end

assets do
  entry "app.ts"
  url_prefix "/assets"
end

islands do
  adapter :vue
end

collection :articles, "content/articles" do
  permalink "/writing/:slug/"
  layout "article.astral"

  schema do
    field :title, :string, required: true
    field :description, :string, required: true
    field :date, :date, required: true
    field :updated, :date
    field :draft, :boolean, default: false
    field :language, :string, default: "en"
    field :tags, {:array, :string}, default: []
  end
end
