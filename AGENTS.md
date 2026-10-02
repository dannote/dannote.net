# Blog

This is the Astral-powered static site for `dannote.net`. Astral is the Elixir static-site generator from `elixir-volt/astral`—do not confuse it with the JavaScript framework Astro. Volt owns browser assets, development serving, and HMR.

## Working with Astral

Before changing site structure, routing, layouts, content collections, Markdown components, assets, islands, feeds, sitemaps, or deployment behavior:

1. Read Astral's documentation index at <https://hexdocs.pm/astral/llms.txt>.
2. Read only the linked guides relevant to the task. Start with:
   - Getting started: <https://hexdocs.pm/astral/getting-started.html>
   - Pages and layouts: <https://hexdocs.pm/astral/pages-and-layouts.html>
   - `.astral` templates: <https://hexdocs.pm/astral/astral-templates.html>
   - Content collections: <https://hexdocs.pm/astral/content-collections.html>
   - Configuration: <https://hexdocs.pm/astral/configuration.html>
   - Assets and browser code: <https://hexdocs.pm/astral/assets.html> and <https://hexdocs.pm/astral/ui-and-browser-code.html>
3. Prefer the installed dependency's documentation and source when behavior depends on the exact locked version. Inspect `mix.lock`, use Elixir dependency/docs introspection when available, or read `deps/astral/`; do not assume Astro conventions apply.

Astral uses `{:astral, "~> 0.5.0"}`. Keep changes compatible with the version resolved in `mix.lock`.

## Project structure

- `astral.config.exs` — Astral configuration, layouts, collections, plugins, generated routes, and asset entries.
- `pages/` — file-based Markdown, HTML, and `.astral` pages.
- `layouts/` — shared page and collection layouts.
- `assets/` — Volt-managed TypeScript, CSS, and imported browser assets.
- `public/` — files copied unchanged to the static output.
- `lib/` — project-specific Elixir modules.
- `scripts/` — one-off generators for committed assets, run with `mix run`.
- `dist/` — generated static output; never edit or commit it.

## Components

- `components/` is discovered recursively; Astral names a component by its path with underscores, so `components/site/header.astral` is `<.site_header />`. Folders are prefixes.
- `site/` is the chrome, `writing/` the index entry, `article/` what any article may use: contents, meta, callout, code pane, link card, supervision tree. Blocks that belong to one post live in a folder named after it, such as `building_this_year/`; the generic primitives stay at the top level.
- A component call inside Markdown stays on one line. A tag that spans lines makes MDEx treat the rest of the document as raw HTML. Data belongs in the component's preamble, not in attributes.
- A module named more than once in a file gets an `alias`: at the top of an `.astral` preamble, which also covers its template, or of an Elixir module. A Markdown page cannot hold setup code, so repeated logic there moves into a component.
- Code that no grammar can highlight, or that is colored by role rather than syntax, is written as data: lines of `{token, text}` segments rendered by `Blog.Highlight` through `<.article_code_pane>`. Never hand-write spans in a template; the formatter reflows them.
- Every illustration in an article is wrapped in `<.article_figure id="…" caption="…">`, which draws the rules, labels the figure by its caption, and adds the slow ambient background. Don't hand-write `<figure>` wrappers.
- Type: pages use Helvetica Neue where the visitor has it (Apple devices) and the self-hosted Inter in `assets/fonts/` everywhere else; never preload Inter, or Apple devices download it too. Social cards and generated drawings use TeX Gyre Heros from `priv/fonts/`, a free Helvetica, with Inter for Cyrillic text. The reasons are in the comments in `assets/styles.css` and `Blog.SocialImages`.
- Fenced code is highlighted by Lumis, one `lumis_wasm_*` package per language in `mix.exs`. A fence in a language with no package renders plain.
- Islands are Vue files under `assets/islands/`, their composables under `assets/composables/`, mounted with `<.vue component="islands/Name.vue" client={:visible} props={...}>` and static children as the pre-hydration content. The Vue runtime comes from `package.json`.

## Styling

- Tailwind utilities by default, on markup we write.
- Plain CSS in `assets/styles.css` only for: markup we don't write (Markdown, plugin output, embeds); keyframes, scroll timelines, `@supports`, `@page`, pseudo-elements with real content; page-wide defaults; utilities needing 3+ stacked variants or 2+ arbitrary values. Each feature block says why in a comment.
- Shared values are tokens in `@theme`: colours, durations, sizes. Use colour tokens whole: `border-rule-strong`, not `border-copy/25`. No colour literals outside `@theme` and print. A one-off arbitrary value or element-local measurement is fine.
- A semantic class (`figure`, `article-toc`) exists only as a hook for CSS or scripts. Repeated utility strings become a component; never `@apply`.
- Order in `styles.css`: fonts, tokens, base, one components block per feature, print.

## Content conventions

- An X post is a blockquote ending in `— Name (@handle), [date](url)`; `Blog.Markdown.XPosts` marks it and `assets/x-posts.ts` swaps in the embed on load. Put the poster frame of a video in the quote as an image under `assets/images/x/`.
- A URL posted on its own becomes `<.article_link_card href="..." />`. `Blog.LinkPreview` fetches the page once at build time; the cache in `content/link_previews.json` and the images in `assets/images/links/` are committed, so builds run offline. Delete a cache entry to refetch.
- Every mention of one of the author's projects links to it; an external technology links once, on first mention.
- `.reach.exs` is the architecture policy, checked in `mix ci`. Keep it true when adding modules.

Use HEEx semantics in `.astral` templates and local components. `Astral.Formatter` integrates `.astral` templates with `mix format`; Markdown and CSS are not covered by that plugin. Content collections use Markdown with YAML frontmatter and schemas declared in `astral.config.exs`. Prefer Astral's built-in APIs and components over hand-rolled routing, asset, image, feed, or sitemap behavior.

## Development

```sh
mix deps.get
mix astral.dev
mix astral.build
mix ci
```

- Use `mix astral.dev` for local development; add `--open` only when opening a browser is wanted.
- Run `mix astral.build` after routing, content, layout, or asset changes and inspect the generated route table.
- Run `mix ci` before finishing.
- `.github/workflows/ci.yml` runs `mix ci` and deploys `dist/` to the Cloudflare Pages project `dannote-net`: production from `main`, a preview per pull request with its URL in a comment. Tool versions come from `.tool-versions`, shared with mise. A manual deploy is `wrangler pages deploy dist --project-name dannote-net --branch main` after `mix astral.build`.

# VibeKit quality gate

## Quality checks

```sh
mix deps.get
mix ci
```

## Conventions

- Use `mix ci` for the full validation suite before finishing changes.
- For Phoenix/web apps, keep Phoenix's generated guidance, but treat this VibeKit section as the final quality gate.
- For non-web Elixir projects, VibeKit is the default project baseline.
- Keep changes small, tested, and formatted.
