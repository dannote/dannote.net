# dannote.net

Danila Poyarkov's personal site, and a working example of building a site in Elixir from start to finish.

It's built with [Astral](https://github.com/elixir-volt/astral), a static site generator for Elixir, and [Volt](https://github.com/elixir-volt/volt), which handles browser assets and the dev server. Pages are HEEx templates and Markdown. Content is typed collections. TypeScript, Tailwind CSS, syntax highlighting, and social cards all build inside the BEAM, so building the site doesn't need Node.js.

## What's in here

### Pages are templates with Elixir in them

An `.astral` page is a HEEx template with an Elixir setup block. The homepage lists the latest articles straight from the collection ([`pages/index.astral`](pages/index.astral)):

```heex
---
articles =
  @site
  |> Astral.Collection.entries(:articles)
  |> Astral.Collection.published()
  |> Astral.Collection.sort_by_date(:desc)
  |> Enum.take(6)

assigns = assign(assigns, :articles, articles)
---
<ul>
  <li :for={article <- @articles}>
    <.writing_entry entry={article} />
  </li>
</ul>
```

Layouts and components work the same way, in [`layouts/`](layouts) and [`components/`](components).

### Articles are a typed collection

Articles are Markdown with YAML frontmatter, checked against a schema declared in [`astral.config.exs`](astral.config.exs):

```elixir
collection :articles, "content/articles" do
  permalink("/writing/:slug/")
  layout("article.astral")

  schema do
    field(:title, :string, required: true)
    field(:date, :date, required: true)
    field(:draft, :boolean, default: false)
    field(:tags, {:array, :string}, default: [])
  end
end
```

Markdown can use components too. A note can quote the X post it replies to:

```heex
<.x_post kind="reply" name="Pietro Schirano" handle="skirano" date="2026-06-11" url="https://x.com/skirano/status/2065096311410409770">
  You should basically never use Fable for coding, but instead use it as a planner/orchestrator.
</.x_post>
```

### Everything else a blog needs comes from plugins

- `Astral.Plugin.Feed` writes the Atom feed for the articles.
- `Astral.Plugin.Sitemap` writes `sitemap.xml`.
- `Astral.Plugin.LLMs` writes [`llms.txt`](https://llmstxt.org) for language models.
- [`Blog.SocialImages`](lib/blog/social_images.ex) is a plugin written for this site. It draws a 1200 × 630 Open Graph card for every article with [Skia](https://hex.pm/packages/skia), and needs neither a headless browser nor an image service.

### Builds don't need Node.js

- **TypeScript** in [`assets/`](assets) is bundled by Volt with [OXC](https://hex.pm/packages/oxc), the Rust JavaScript toolchain, through native bindings.
- **Tailwind CSS 4** is compiled by Tailwind's own compiler, running inside the BEAM on [QuickBEAM](https://hex.pm/packages/quickbeam). npm packages such as `@tailwindcss/typography` are fetched by an Elixir npm client.
- **Code blocks** are highlighted at build time by [Lumis](https://hex.pm/packages/lumis) with light and dark themes, so the browser runs no highlighter.
- **Icons** come from Iconify and are inlined at build time.

### The dev server shows errors in the browser

`mix astral.dev` serves the site with hot module reloading. Template errors, compile errors in [`lib/`](lib), and broken config show up in an overlay with the file, line, and source. Changes to `astral.config.exs` and `lib/` apply without a restart, and open pages reload on their own.

### One command checks everything

`mix ci` runs the full quality gate:

- compilation with warnings as errors, and formatting for Elixir, HEEx templates, and TypeScript;
- type-aware TypeScript linting with tsgolint;
- a full site build and the tests;
- Credo, Dialyzer, a duplicate-code check, and architecture and code-smell checks from [Reach](https://github.com/elixir-vibe/reach).

## Running it

```sh
mix deps.get
mix astral.dev      # http://localhost:4000, add --open to open a browser
mix astral.build    # writes the static site to dist/
mix ci
```

## Layout

| Path | What it holds |
| --- | --- |
| `pages/` | Pages: Markdown and `.astral` templates, routed by file path |
| `content/articles/` | Articles and notes, the `:articles` collection |
| `layouts/`, `components/` | Shared layouts and HEEx components |
| `assets/` | TypeScript and Tailwind CSS, built by Volt |
| `public/` | Files copied to the output as they are |
| `lib/blog/` | Site code: identity and the social card plugin |
| `astral.config.exs` | Collections, plugins, layouts, and Markdown options |

Icons used on the site are listed in `priv/iconify/manifest.json`, which is committed so builds don't download them again. The Noto Sans fonts for social cards are in `priv/fonts/`, with their SIL Open Font License.

## Start your own

```sh
mix archive.install hex igniter_new
mix igniter.new my_site --install astral
cd my_site && mix astral.dev
```

See the [Astral documentation](https://hexdocs.pm/astral) and the [Volt documentation](https://hexdocs.pm/volt).
