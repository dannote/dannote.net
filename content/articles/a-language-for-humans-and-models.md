---
title: "A language for humans and models"
description: "JSX, structured JSON, and Bash are steps toward one declarative language, and models are learning behavior, not just text."
date: 2026-05-01
language: en
kind: Note
draft: false
sources:
  - https://x.com/dan_note/status/2050305954088960221
  - https://x.com/dan_note/status/2050313886084075545
---

If you think a bit deeper about what [Remotion](https://www.remotion.dev) is doing, and what I was doing when I chose JSX as the primary language for [`figma-use`](https://github.com/dannote/figma-use) templates and OpenPencil templates for CLI and MCP, it’s the same idea. We’ve all been searching for a universal language that is understandable to both LLMs and humans, and expressive enough to describe sophisticated ideas declaratively.

Plain text isn’t enough. You can see hints of this in models like Nano Banana, where users discovered that well-structured JSON produces far more deterministic and higher-quality results.

Coding agents, which mostly express their intent through compact and concise Bash commands, are also a step in that direction.

My intuition is that Elixir, with its expressive syntax and first-class metaprogramming, is the next step.

## Approximating behavior

There is a second reason this matters. LLMs have recently been drifting from just approximating the next token to approximating behavior.

The general knowledge they absorbed from sources like Common Crawl isn’t intelligence, not even a real approximation of it. We started seeing early signs of intelligence when we placed them in constrained environments like coding harnesses and made them act.

By applying LLMs in different harnesses — coding, design, and others — we’re effectively breaking through the limitations model producers face. What matters here is how models act in specialized environments guided by human experts. This kind of data can’t be collected from static sources.

At this point, the most important thing is the ability to capture high-quality feedback on these actions.

So when I build tools for vibe-coding, I’m also thinking about how they can be used to validate synthetic datasets for future models, where better actions can gradually turn into more inherent intelligence.
