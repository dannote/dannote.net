import Astral.Config

root(".")
outdir("dist")

markdown(
  syntax_highlight: [
    engine: :lumis,
    opts: [
      formatter:
        {:html_multi_themes,
         themes: [light: "github_light", dark: "github_dark"], default_theme: "light-dark()"}
    ]
  ]
)

plugin(Astral.Plugin.Feed,
  site_url: "https://dannote.net",
  title: "Danila Poyarkov — Writing",
  author: "Danila Poyarkov",
  collection: :articles
)

plugin(Astral.Plugin.Sitemap, site_url: "https://dannote.net")
plugin(Blog.SocialImages)

plugin(Astral.Plugin.LLMs,
  site_url: "https://dannote.net",
  title: "Danila Poyarkov",
  description: "Open-source projects, technical writing, and personal links.",
  sections: [
    {"About", ["/about/", "/projects/"]},
    {"Writing", ["/writing/", {:collection, :articles}]},
    {"Optional", ["/elsewhere/"]}
  ]
)

layouts do
  default("site.astral")
end

assets do
  entry("app.ts")
  url_prefix("/assets")
end

islands do
  adapter(:vue)
end

collection :articles, "content/articles" do
  permalink("/writing/:slug/")
  layout("article.astral")

  schema do
    field(:title, :string, required: true)
    field(:description, :string, required: true)
    field(:date, :date, required: true)
    field(:updated, :date)
    field(:draft, :boolean, default: false)
    field(:language, :string, default: "en")
    field(:kind, :string, default: "Essay")
    field(:tags, {:array, :string}, default: [])
  end
end
