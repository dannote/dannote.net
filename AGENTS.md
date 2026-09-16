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

Astral uses `{:astral, "~> 0.3.2"}`. Keep changes compatible with the version resolved in `mix.lock`.

## Project structure

- `astral.config.exs` — Astral configuration, layouts, collections, plugins, generated routes, and asset entries.
- `pages/` — file-based Markdown, HTML, and `.astral` pages.
- `layouts/` — shared page and collection layouts.
- `assets/` — Volt-managed TypeScript, CSS, and imported browser assets.
- `public/` — files copied unchanged to the static output.
- `lib/` — project-specific Elixir modules.
- `dist/` — generated static output; never edit or commit it.

Use HEEx semantics in `.astral` templates and local components. Extract repeated template styling into shared components and prefer Tailwind utilities and named theme tokens over repeated arbitrary values. `Astral.Formatter` integrates `.astral` templates with `mix format`; Markdown and CSS are not covered by that plugin. Content collections use Markdown with YAML frontmatter and schemas declared in `astral.config.exs`. Prefer Astral's built-in APIs and components over hand-rolled routing, asset, image, feed, or sitemap behavior.

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
