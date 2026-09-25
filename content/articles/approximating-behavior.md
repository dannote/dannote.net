---
title: "Approximating behavior"
description: "Why constrained environments and high-quality action feedback matter more than static training data."
date: 2026-05-01
language: en
kind: Note
draft: true
sources:
  - https://x.com/dan_note/status/2050313886084075545
---

One more thought on this. LLMs have recently been drifting from just approximating the next token to approximating behavior.

The general knowledge they absorbed from sources like Common Crawl isn’t intelligence, not even a real approximation of it. We started seeing early signs of intelligence when we placed them in constrained environments like coding harnesses and made them act.

By applying LLMs in different harnesses — coding, design, and others — we’re effectively breaking through the limitations model producers face. What matters here is how models act in specialized environments guided by human experts. This kind of data can’t be collected from static sources.

At this point, the most important thing is the ability to capture high-quality feedback on these actions.

So when I build tools for vibe-coding, I’m also thinking about how they can be used to validate synthetic datasets for future models, where better actions can gradually turn into more inherent intelligence.
