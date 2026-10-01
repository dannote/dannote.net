---
title: "Approximating behavior"
description: "Models learn the most from acting in constrained environments, which makes feedback on their actions the valuable data."
date: 2026-05-01
language: en
kind: Note
draft: false
sources:
  - https://x.com/dan_note/status/2050313886084075545
---

Language models started as next-token predictors, and lately they have been drifting toward approximating behavior.

The general knowledge they absorbed from sources like Common Crawl isn’t intelligence, not even a real approximation of it. We started seeing early signs of intelligence when we placed models in constrained environments like coding harnesses and made them act: change a file, run the tests, read the error, try again.

That loop is what I keep building for other domains. [`figma-use`](https://github.com/dannote/figma-use) gives a design agent the cycle a coding agent already has: it edits the actual document, sees a visual diff of what changed, and runs a design linter before deciding what to do next. [Reach](https://github.com/elixir-vibe/reach) turns an architecture into rules an agent can check, so a change that crosses a boundary fails instead of slipping through review.

A harness like this does two things. It makes today’s models more useful, and it produces data no crawl contains: what an agent tried in a specialized environment, what the environment answered, and what a human expert accepted. That kind of data can’t be collected from static sources, which is how harnesses help break through the limits model producers face.

So the scarce resource is high-quality feedback on actions. When I build tools for vibe-coding, I also think of them as a way to validate synthetic datasets for future models. If a harness can reliably tell a better action from a worse one, the better actions can be kept and learned from, and some of what we now get from the harness can become part of the model itself.
