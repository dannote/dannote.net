---
title: "What coding agents need"
description: "Reading existing code, understanding architecture, and checking for drift."
date: 2026-07-02
language: en
kind: Note
draft: false
---

*Originally posted on [X](https://x.com/dan_note/status/2072655266126979558).*

BTW, that’s the primary reason I’m very skeptical about coding-agent swarms burning zillions of tokens. I don’t mean to insult anyone, but the last time I looked at @openclaw’s code, it was in pretty bad shape.

There are three fundamental things you need to do constantly in your so-called loops if you want to keep a codebase healthy.

First, you need to force the agent to read the existing code to understand your style implicitly. Agents are tuned to read less and more selectively to save space in the context window. This is especially bad in JS codebases, where historically there have been too many coding styles across the ecosystem. Unless you show the agent examples of your style, expect a dice roll every time.

Second, you need to remind the agent to look around. It should be able to inspect the surrounding architectural slice to learn what entities already exist, how they relate to each other, and how the source tree is organized. Otherwise it will tend to satisfy the “business need” by taking the shortest path, like the laziest junior developer. It will likely introduce duplicate entities and multiple implementations of the same concepts, then evolve them independently, making the situation worse over time. It will reimplement functionality that already exists in the standard library or the ecosystem, create ad hoc test files, favor loosely connected internal abstractions, and later spend a lot of effort “normalizing” data between them. Over time, the codebase will gradually drift away from the architecture you originally built.

None of this is really the agent’s fault. These are failures of the environment, not the model itself. Give it the right hints, the right context, and the right tools, and it can avoid most of these problems and write the code properly.

Third and last, if you don’t want to waste your time babysitting the agent and repeatedly enforcing best practices, you need to give it the tools. Prompts, skills, or whatever you want to call them, will never fully override the model’s innate behavioral patterns. You need an automated oracle that continuously checks the output for style, code duplication, antipatterns, and architectural drift.

A simple linter setup won’t help much, because most linters are still designed to catch human mistakes. Agents make those mistakes too, but they also introduce an entirely new class of problems on top of them.

The real problem isn’t the models anymore. They’re already pretty strong. The real problem is the setup around them.

Given that barely any of this has been seriously addressed by the coding harnesses from the major AI labs, I have the feeling that very few of them actually care about what it takes to build and maintain high-quality software.

Claude Code itself is proof of that.
