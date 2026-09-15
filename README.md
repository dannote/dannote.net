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

Astral documentation: <https://hexdocs.pm/astral>
