---
title: "Forty packages, one maintainer"
description: "How I handle pull requests when AI makes them cheap to open and expensive to review."
date: 2026-06-06
language: en
kind: Note
draft: false
sources:
  - https://x.com/dan_note/status/2052420226948432079
  - https://x.com/dan_note/status/2063400985553469912
---

Since the beginning of the year, the number of projects I actively maintain across several ecosystems has grown to more than 40 packages.

I do my best to respond quickly and help with adoption. I’ve done my best to extract signal even from the worst PRs. But my capacity is limited, so here is how I handle pull requests in these dark times.

If a PR is well-written overall but I only have a few nitpicks, I often merge it and make a follow-up commit myself. The review back-and-forth is often more expensive, and it’s harder to keep track of many conversations.

If a PR isn’t in great shape and I’m not willing to merge it, I treat it as an open issue instead. If it contains good ideas or useful hints on how to fix things, I do a “vibe-merge”: I implement the code myself but add the original author as a co-author to give proper credit.

Otherwise, I close it with a polite AI-generated reply.

Many people are saying that OpenPencil has one of the most generous pull request policies anywhere in the world. Frankly, they’re probably right. So pull requests that don’t follow [CONTRIBUTING.md](https://github.com/open-pencil/open-pencil/blob/master/CONTRIBUTING.md) are now rejected automatically.
