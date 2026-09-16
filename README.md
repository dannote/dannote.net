# dannote.net

Danila Poyarkov’s personal website: open-source projects, writing, and a few personal links.

Built with [Astral](https://hexdocs.pm/astral), Elixir, and Tailwind CSS. Pages are static semantic HTML; Vue adds optional controls to the system diagram.

## Development

```sh
mix deps.get
mix astral.dev
```

Use `mix astral.dev --open` to open the local site automatically.

## Build

```sh
mix astral.build
```

The static site is written to `dist/` (not committed).

## Checks

```sh
mix ci
```

## Content

- Add standalone Markdown or `.astral` pages under `pages/`.
- Add articles under `content/articles/`; collections, feeds, and routes are configured in `astral.config.exs`.
- Add shared layouts under `layouts/`.
- Add browser assets under `assets/`; Volt builds and serves them.
- Put files copied verbatim into the output under `public/`.

## Icons

The small `priv/iconify/manifest.json` is committed so builds can render the
selected icons without fetching them again. Downloaded sets under
`priv/iconify/sets/` are an ignored cache. Until PhoenixIconify discovers icons
inside Markdown, their names are listed in `config/config.exs`.

Icons are explicit PhoenixIconify components, not inferred from URLs. Shared `icon_link`, `nav_link`, and `profile_links` components keep leading icons, navigation state, and profile destinations consistent. Prose links and source attributions stay plain; the footer feed and profile links have icons.

## Formatting and highlighting

`mix format` covers Elixir, `.astral` templates, and JavaScript/TypeScript. Template formatting delegates to Elixir, Phoenix HEEx, and Volt. Markdown and CSS are not currently source-formatted by this pipeline.

Lumis renders language-tagged code blocks at build time with light/dark themes, using the Markdown options provided by Astral 0.3.2.

## Social cards

`Blog.SocialImages` is a site-local Astral plugin using Skia. It generates a default
1200 × 630 PNG and one card per published article under `/social/`. The shared
head component emits absolute Open Graph/X image URLs and alt text.

The renderer owns named copy, palette, typography, and layout constants. Noto Sans
Regular and Bold are bundled under `priv/fonts/` for reproducible Latin/Cyrillic
text; their SIL Open Font License is included there. Cards render locally during
builds and through the same route callback in development—no browser or remote
image service is required.

Astral documentation: <https://hexdocs.pm/astral>
