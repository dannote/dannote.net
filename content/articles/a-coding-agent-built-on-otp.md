---
title: "A coding agent built on OTP"
description: "Vibe puts Elixir eval, stateful sessions, and supervised subagents at the center of a coding agent."
date: 2026-05-22
language: en
kind: Note
draft: false
sources:
  - https://x.com/dan_note/status/2057966143369777407
---

A lot of people expressed interest, so I decided to open-source [Vibe](https://github.com/elixir-vibe/vibe) earlier than planned.

Vibe combines the vibe-coding tools I’ve been building into an Elixir-focused coding agent. But it is not only about coding: the goal is to support background tasks, long-running agent workflows, and access through Telegram and other gateways.

Some highlights:

- **Elixir eval is the primary tool interface.** This makes it possible to unify many actions behind one composable interface, in a Unix-like way, without constant serialization churn.
- **Sessions are stateful.** Similar to Livebook, the agent can store and reference intermediate results naturally.
- **It is built on OTP.** Unlike most agent harnesses, Vibe can deeply introspect and supervise its own internal state.
- **Agents can launch other agents.** Subagents are supervised OTP processes with their own sessions, which enables more sophisticated long-running and parallel workflows.
- **Agents can reach other machines.** Vibe supports remote access over SSH and Erlang distribution, so agents can connect to remote nodes and communicate across machines.
- **The agent can work on itself.** It can inspect, patch, verify, and hot-reload parts of Vibe, while tools like [Reach](https://github.com/elixir-vibe/reach) help keep boundaries clean.

Around that, there is a TUI, a LiveView web interface, persistent sessions, SQLite-backed storage, semantic events, plugins, skills, gateways, and local telemetry.

This is still an early research preview. Use it at your own risk, expect rough edges, and be careful.
