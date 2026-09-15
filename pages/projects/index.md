---
title: Projects
description: Open-source tools by Danila Poyarkov for design automation, code intelligence, and the Elixir ecosystem.
---

# Projects

Most of my current work concerns coding agents: giving them access to structured documents, code, and running systems rather than just text and screenshots.

## Design tools

- [OpenPencil](https://openpencil.dev) — an AI-native, open-source design editor and Figma alternative built with Skia and WebGL.
- [figma-use](https://github.com/dannote/figma-use) — structural queries, JSX rendering, diffs, linting, editing, and exports through a CLI for Figma.

## Code intelligence for Elixir

- [Vibe](https://github.com/elixir-vibe/vibe) — an experimental BEAM-native coding agent runtime.
- [Reach](https://github.com/elixir-vibe/reach) — program-dependence graphs, call and data flow, effect analysis, and architecture checks.
- [Exograph](https://github.com/elixir-vibe/exograph) — structural Elixir code search built with ExAST, Reach, Ecto, and Postgres/ParadeDB.
- [ex_ast](https://github.com/elixir-vibe/ex_ast) — AST-aware search, replacement, and structural diffs.
- [ex_dna](https://github.com/elixir-vibe/ex_dna) — duplicate-code detection with extraction candidates.
- [ex_slop](https://github.com/elixir-vibe/ex_slop) — Credo checks for recurring low-quality patterns in generated code.
- [program_facts](https://github.com/elixir-vibe/program_facts) — generated programs with known structural facts for testing analyzers.

## Frontend tooling inside the BEAM

- [Volt](https://github.com/elixir-volt/volt) — frontend builds and development serving for Phoenix, with HMR, Tailwind, and support for JavaScript, TypeScript, Vue, Svelte, React, and Solid.
- [Astral](https://github.com/elixir-volt/astral) — a Volt-powered static site generator. This site uses it.
- [QuickBEAM](https://github.com/elixir-volt/quickbeam) — a JavaScript runtime with browser-like APIs backed by OTP.
- [Phoenix Vapor](https://github.com/elixir-volt/phoenix_vapor) — Vue templates compiled into native Phoenix LiveView rendering structures.
- [OXC](https://github.com/elixir-volt/oxc_ex), [Vize](https://github.com/elixir-volt/vize_ex), and [Oxide](https://github.com/elixir-volt/oxide_ex) — Elixir bindings for JavaScript, Vue, and Tailwind toolchains.

## Running systems

- [pi-elixir](https://github.com/dannote/pi-elixir) — runtime and code-structure tools for the Pi coding agent.
- [phoenix_replay](https://github.com/dannote/phoenix_replay) — recording and replay for LiveView sessions.
- [live_render](https://github.com/dannote/live_render) — server-driven generative UI for LiveView.
- [phoenix_streamdown](https://github.com/dannote/phoenix_streamdown) — streaming Markdown for incremental LLM output.

## Other work

My [GitHub profile](https://github.com/dannote) also covers earlier work in Ruby, search, Russian NLP, systems programming, and security research.

For the longer explanation of the current work, see [What I’ve Been Building This Year](/writing/what-ive-been-building-this-year/) and [Building Blocks for the Future Web](https://github.com/elixir-vibe/building-blocks).
