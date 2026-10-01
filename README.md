# dannote.net

Danila Poyarkov's personal site, and a working example of building a site in Elixir from start to finish.

It's built with [Astral](https://github.com/elixir-volt/astral), a static site generator for Elixir, and [Volt](https://github.com/elixir-volt/volt), which handles browser assets and the dev server. The whole site builds inside the BEAM: TypeScript, Tailwind CSS, syntax highlighting, and social cards included. There's no Node.js and no bundler config.

## What's in here

### The whole frontend builds inside the BEAM

`mix astral.build` runs without Node.js installed:

- **TypeScript** in [`assets/`](assets) is bundled by Volt with [OXC](https://hex.pm/packages/oxc), the Rust JavaScript toolchain, through native bindings.
- **Tailwind CSS 4** is compiled by Tailwind's own compiler, running inside the BEAM on [QuickBEAM](https://hex.pm/packages/quickbeam). npm packages such as `@tailwindcss/typography` are fetched by an Elixir npm client.
- **Code blocks** are highlighted at build time by [Lumis](https://hex.pm/packages/lumis) with light and dark themes, so the browser runs no highlighter.
- **Social cards** are drawn by [`Blog.SocialImages`](lib/blog/social_images.ex), a plugin written for this site. It renders a 1200 × 630 Open Graph image for every article with [Skia](https://hex.pm/packages/skia), with no headless browser and no image service.
- **Icons** come from Iconify and are inlined at build time.

### Pages are templates with Elixir in them

An `.astral` page is a HEEx template with an Elixir setup block. The homepage lists the latest articles straight from the collection ([`pages/index.astral`](pages/index.astral)):

```heex
---
alias Astral.Collection

articles =
  @site
  |> Collection.entries(:articles)
  |> Collection.published()
  |> Collection.sort_by_date(:desc)
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

Markdown plugins work too. A note quotes the X post it replies to as an ordinary blockquote that ends with a link to the post:

```md
> You should basically never use Fable for coding, but instead use it as a planner/orchestrator.
>
> — Pietro Schirano (@skirano), [11 June 2026](https://x.com/skirano/status/2065096311410409770)
```

[`Blog.Markdown.XPosts`](lib/blog/markdown/x_posts.ex), an [MDEx plugin](https://hexdocs.pm/mdex/plugins.html) listed in `astral.config.exs`, marks such quotes at build time. In the browser, [`assets/x-posts.ts`](assets/x-posts.ts) replaces each one with X's embed in the site's theme as the page loads. The quote stays readable everywhere else: on GitHub, in the feed, and without JavaScript.

### Feeds and indexes come from plugins

`Astral.Plugin.Feed` writes the Atom feed, `Astral.Plugin.Sitemap` writes `sitemap.xml`, and `Astral.Plugin.LLMs` writes [`llms.txt`](https://llmstxt.org) for language models. Each is a few lines in `astral.config.exs`.

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

The dev server reloads pages as you edit, applies changes to `astral.config.exs` and `lib/` without a restart, and shows template, compile, and config errors in the browser.

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
