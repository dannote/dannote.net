---
title: "A JavaScript runtime in the BEAM"
description: "QuickBEAM gives every JavaScript runtime a supervision tree, native BEAM terms, and no Node.js on the machine."
date: 2026-03-12
language: en
kind: Note
draft: false
---

*Originally posted on [X](https://x.com/dan_note/status/2032139121850728939).*

I've built a new JavaScript runtime that runs inside the BEAM.

Every JS runtime is a GenServer with its own OS thread. No JSON anywhere — JS objects map to BEAM terms natively through a lock-free queue.

What makes it different from running Node/Deno/Bun alongside Elixir:

→ JS runtimes live in supervision trees. They crash, restart, recover state — standard OTP
→ `fetch()` goes through `:httpc`. WebSocket through `:gun`. `crypto.subtle` through `:crypto`. `BroadcastChannel` through `:pg` — works across a cluster
→ The DOM is lexbor (C library). JS renders into it, Elixir reads it directly — no serialization, no re-parsing
→ Workers are BEAM processes. They get preemptive scheduling for free
→ TypeScript toolchain (OXC) and npm client built in — no Node.js on the machine at all

Full control over the JS layer: parse ASTs, bundle imports, transform TypeScript, minify — all from Elixir via OXC NIFs.

Use cases:

— SSR with Preact/React into native DOM, Elixir reads the tree
— Sandboxed user-defined business rules with memory limits, timeouts, and a controlled API surface
— Parallel Workers that compute and broadcast via distributed process groups
— Evaluating or bundling TypeScript without any external toolchain
— Running npm packages inside the BEAM

Still a research project in early beta. Covered with tests including Web Platform Tests ports, but expect rough edges.

[QuickBEAM](https://github.com/elixir-volt/quickbeam)
