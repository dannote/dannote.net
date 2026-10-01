---
title: "Three days, one developer"
description: "Figma shipped a silent patch to kill figma-use, so I recreated the core of it as OpenPencil in a weekend."
date: 2026-03-01
language: en
kind: Note
draft: false
sources:
  - https://x.com/dan_note/status/2028201388074013048
---

Figma shipped a silent patch specifically to kill [`figma-use`](https://github.com/dannote/figma-use) — my open-source tool that did what they wouldn't: an MCP server that creates and modifies designs, JSX export, design linting. Then they scrambled to catch up with their own MCP server.

So I spent the weekend recreating Figma from scratch.

OpenPencil: reads and writes `.fig` files, AI chat with full design tools, P2P collaboration with zero servers, ~7 MB app. No account, no subscription.

Three days, one developer, MIT license.

<.article_link_card href="https://openpencil.dev" title="OpenPencil" description="A free, open-source design editor that reads and writes .fig files. Desktop and web." />
