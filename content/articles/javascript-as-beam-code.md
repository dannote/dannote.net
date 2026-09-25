---
title: "JavaScript as BEAM code"
description: "QuickBEAM 0.11 adds a JavaScript interpreter written in Elixir, so the BEAM can preempt, limit, and supervise it."
date: 2026-08-14
language: en
kind: Note
draft: false
sources:
  - https://x.com/dan_note/status/2088248012778705381
---

[QuickBEAM 0.11](https://github.com/elixir-volt/quickbeam/releases/tag/v0.11.0) includes an experimental JavaScript interpreter written in Elixir.

JavaScript is compiled with QuickJS, verified, and can be pinned at startup. Each execution gets fresh state, preventing data from leaking between requests or jobs.

Because execution happens as BEAM code, Erlang can preempt and account for it like any other process. Under concurrent load, this should provide fairer scheduling and more predictable latency than work hidden behind a native runtime boundary.

Step, stack, memory, and wall-clock limits contain failures to a single evaluation.

This brings BEAM scheduling, isolation, and supervision to SSR, templates, user scripts, and small edge-style functions. For now, it supports a limited, tested JavaScript profile rather than the full browser or Node.js environment.

The [original QuickBEAM runtime](/writing/a-javascript-runtime-in-the-beam/) still runs each JavaScript runtime on its own OS thread; the interpreter is for work that should live under the BEAM scheduler instead.
