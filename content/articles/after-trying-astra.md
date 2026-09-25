---
title: "After trying Astra"
description: "Long-term direction, conversational boundaries, and the limits of current models."
date: 2026-09-10
language: en
kind: Note
draft: false
sources:
  - https://x.com/dan_note/status/2098107980818358339
---

When Astra came out, looking at all the cool demos, I started to think that I had to review and rethink the whole concept behind the projects I’ve been working on.

After using it for a few days, I can conclude that while it is significant progress, there is still nothing paradigmatically new. It looks like we’ve plateaued across a whole set of cognitive abilities.

First, Astra, like other models, is still not critical enough of itself. It relies heavily on previous context compactions, doesn’t stop to take a bird’s-eye view of what has been done, and therefore isn’t capable of maintaining and updating a long-term vision.

This isn’t about having a checklist in a Markdown file. Sometimes you have to stop, reflect on the direction you’re going in, and make corrections with some degree of autonomous will.

Second, it still isn’t able to maintain strict boundaries within a conversation. I often ask models to prepare a draft of a reply to a PR, and they consistently fail either by leaking details from the internal conversation or by stepping out of my role and adding things like “X tests passed.”

This isn’t specific to Astra. All frontier models are still very bad at separating the conversational context from what should be retained in the code or shared with a third party, as well as what should remain private and what each party is already aware of. [Zack noticed](https://x.com/zack_overflow/status/2076361674014015600) the same thing with Fable back in July: code comments that reference details from the chat and make little sense to anyone reading the codebase.

Of course, this can be tuned with a long prompt containing a set of example situations and appropriate replies, but that would still be imitation rather than understanding.

Third, long-tail sampling artifacts aren’t going anywhere either. Astra can still occasionally stop abruptly, mix up parts of words, or inject random fragments into otherwise coherent output. Once that happens, it won’t be able to recover on its own.

So it’s not AGI yet. Not even close.

Learning how to answer questions and learning how to code, no matter how complex the resulting code is, still doesn’t expose the model during training to the whole variety of behaviors that are natural for human beings.

So my approach is still valid: build environments where existing model capabilities, with some human guidance, can be used to collect enough data to train different behaviors. That’s how `figma-use`, and later OpenPencil, started.
