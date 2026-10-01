---
title: What I’ve Been Building This Year
description: An end-to-end open-source platform for startup factories, assembled one missing building block at a time.
subtitle: "Or: my roadmap for turning Figma into a penny stock."
date: 2026-10-01
updated: 2026-10-01
language: en
draft: false
tags:
  - open source
  - coding agents
  - Elixir
  - design tools
---


Since the beginning of this year, I have released dozens of open-source projects.

There is a Figma-compatible design editor, a JavaScript runtime for the BEAM, a frontend build tool, an npm client, several static analyzers, coding-agent tools, a DuckDB adapter, session replay, deployment tooling, and many smaller libraries between them.

Judging by my timeline, it probably looks like I wake up every few days with an unrelated idea, build it, publish it, and move on to the next one.

That is partly my fault. I have explained each project when I released it, but I have never properly explained how they fit together.

They are all parts of the same system.

## TL;DR

I am building an end-to-end open-source platform for startup factories.

By a “startup factory,” I mean an environment that follows a product through its entire lifecycle: collecting references, exploring ideas, iterating on designs, building real prototypes, writing and verifying the application, deploying it, acquiring users, observing what they do, understanding the economics, and deciding what to improve next.

The process starts in OpenPencil, where a founder can brainstorm with virtual designers and compare several directions instead of trying to generate the final design in one shot. The selected designs can evolve into working Vue components rather than disposable Figma prototypes. From there, the same product moves into an Elixir-based environment that connects coding, deployment, and operation instead of treating them as separate worlds.

The point of bringing these parts together is not only convenience. An agent should be able to understand the whole product instead of seeing one repository or one error log at a time. If a customer gets stuck, the system should be able to trace where they came from, replay what they experienced across the frontend and backend, inspect the relevant runtime and code paths, and propose a next step supported by evidence.

My ambition is to build an open-source vibe-coding platform that can eventually compete with companies such as Figma, Lovable, and Replit, but designed around the needs of technical founders like me.

This is the story of how I arrived there, one missing building block at a time.

## Who I am

I am a programmer, but I have never stayed in one narrow part of the stack. I have done systems programming and contributed to open source across the [Xfce](https://gitlab.xfce.org/xfce/garcon/-/commit/aec77533132eb324180ef771e15226a752573eae) and [nginx](https://github.com/dannote/socks-nginx-module) ecosystems, did white-hat security research through [Google Bug Hunters](https://bughunters.google.com/profile/62602ae8-cf92-4fb0-810c-c9e284f3427e) and [Bugcrowd](https://bugcrowd.com/h/dannote), built web applications, and occasionally worked as a designer. I tend to move to whichever layer contains the problem.

I have also spent a long time working in startup-factory environments. Separately, I have founded and run small companies with my own money.

That made the economics impossible for me to separate from product development. A percentage point of conversion can determine whether a campaign is profitable. Customer acquisition cost, margins, infrastructure, API usage, and the time required to operate a product all affect what to build next and when to stop.

The first part of that process I tried to improve was design.

## It started with Figma

OpenPencil did not begin as an attempt to build a Figma competitor.

I created [`figma-use`](https://github.com/dannote/figma-use) to automate repetitive work in Figma. I wanted to inspect layers, make bulk changes, generate component structures, and export assets without clicking through the interface every time.

Figma had already released an MCP server, but it was not capable of even basic editing. It could expose the canvas to an agent as something close to a node-tree dump, but the agent could not meaningfully work with it.

This was a fundamental limitation. Coding agents did not become useful only because the underlying models became smarter. They became useful because the harnesses around them enabled an iterative process. An agent can inspect a repository, make a change, run the application, read an error, look at the result, compare it with what was expected, and try again.

I wanted to give design agents the same kind of loop.

Good design is iterative too. A designer normally begins by collecting references, then draws several drafts, compares them, and chooses a direction. After that comes a longer loop: copy, tweak, compare, choose, and repeat. The first result is rarely the final one.

Most AI design tools ignore this process. They try to generate a finished screen in one shot. Even when the screenshot looks impressive, the structure underneath is often useless: unnamed nested frames, no components, no tokens, and no coherent system that another designer can continue working with.

With [`figma-use`](https://github.com/dannote/figma-use), an agent could work on the actual structure. It could create and modify nodes, use components and variants, render JSX, inspect the resulting tree, and continue from there. I added visual diffing so it could see what changed. I added design linting so it could catch structural and accessibility problems. I also wanted design files to participate in automated pipelines: linted in CI, compared between revisions, analyzed for inconsistencies, and exported without somebody manually opening Figma.

Then Figma released an update that blocked the debugging interface [`figma-use`](https://github.com/dannote/figma-use) relied on.

I found workarounds and kept the tool working, but the larger lesson was obvious. I could not build this kind of infrastructure on access that a vendor could remove at any moment. If agents were going to treat design as a real programmable medium, the editor itself had to be open.

The official route is not much safer. Figma's remote MCP server now decides which agents may connect at all: sign-in works only for client names on its list, such as Claude Code or Codex. When Mario Zechner tried to connect Pi, his open-source coding agent, Figma refused it because Pi identifies itself as `pi`.

> today in MCP land ...
>
> thing are better compared to a year ago, but also worse.
>
> ![A message: I'm trying to connect to Figma's remote MCP server. Figma only accepts certain client names during sign-in, e.g., Claude Code or Codex, but Pi 0.99.1 always sends pi.](images/x/badlogicgames-2105234146499203255.png)
>
> — Mario Zechner (@badlogicgames), [30 September 2026](https://x.com/badlogicgames/status/2105234146499203255)

That is how [OpenPencil](https://github.com/open-pencil/open-pencil) began.

## OpenPencil became a toolkit

OpenPencil initially gave me an independent environment for the work I had started with [`figma-use`](https://github.com/dannote/figma-use). It could open and write `.fig` files, render them without Figma, and let agents modify the actual document structure.

While refactoring the project, I realized that the editor itself should not be the only useful result. I split the monolith into reusable parts: the `.fig` and Kiwi parsers, scene graph, editor core, CLI, MCP server, and headless Vue SDK. The OpenPencil application is now one consumer of these packages.

The Vue SDK lets developers construct a different editor shell around the same engine. They can embed an editing surface into their product, expose a restricted editor for a particular workflow, or add design tools to an IDE without forking the OpenPencil interface.

The engine does not require an editor UI at all. A script or CI job can query a `.fig` file, lint it, extract tokens, convert it, render it, compare it with another revision, or modify it through the same operations used by the application and its agents.

My goal is to make `.fig` a commodity. If independent software can parse, query, render, modify, and convert the format, it stops being something that can only be fully used inside Figma. It becomes input for other editors, IDEs, automated pipelines, and uses I cannot predict.

This solves access to the design structure, but not the boundary between a design and the application eventually built from it. That is the problem I started exploring with VuePencil.

## From designs to real components

The next direction I started exploring is [VuePencil](https://github.com/dannote/vue-pencil): something like Figma, but for Vue components.

Many visual HTML builders have an abstraction problem. The editor is already an HTML application, and then it tries to build another HTML application inside itself. The layers gradually leak into each other. The tool either supports only a restricted subset of HTML and becomes brittle, or exposes more and more browser internals until it turns into a complicated version of developer tools.

Vue already has a suitable abstraction for this: the VNode tree. In VuePencil, that tree is the source of truth. Editor operations change the model, Vue renders it, and the editor reads the resulting geometry to position selections and handles. It does not directly rewrite the rendered DOM.

This also means that the things placed on the canvas can be real components. The current prototype supports Reka UI primitives, component parts, named slots, props, bindings, and VueUse composables. A switch is not a rectangle that looks like a switch. It remains a `SwitchRoot` with a `SwitchThumb` and can behave like one in preview mode.

The result can be serialized as a normal Vue SFC. Frames and canvas positions remain editor metadata rather than leaking into component CSS. Slots become Vue slots, capabilities become composable calls, and bindings become ordinary Vue expressions.

This makes prototypes much more useful than links between static screens. A founder can continue the design process with working state and interactions, then take the resulting components into the coding environment instead of asking an agent to reconstruct them from a separate design. VuePencil is still an early experiment, but it shows how OpenPencil can evolve beyond Figma compatibility without turning into an HTML builder.

## Why Elixir?

Once the prototype becomes a real application, design is only one part of the problem. You need a backend, storage, background jobs, external APIs, deployment, analytics, and a way for agents to work with all of them. At some point, I realized that the platform needed a common language and runtime through which these parts could expose their APIs.

Elixir seemed like the best fit.

I was initially skeptical when José Valim published [“Why Elixir is the best language for AI”](https://dashbit.co/blog/why-elixir-best-language-for-ai). He referred to [AutoCodeBench](https://autocodebench.github.io/), where Elixir had the highest completion rate across 20 languages. The benchmark was interesting, but his explanation mattered more: immutability makes local reasoning easier, documentation examples are often verified by tests, and the ecosystem has remained stable enough that models encounter fewer generations of conflicting APIs.

After using agents to build more and more Elixir code, I started to agree.

Elixir is dynamic too, so this is not a simple comparison between typed and untyped languages. But data flow is usually explicit, pattern matching exposes many contracts directly in the code, and the language has relatively consistent conventions. The compiler provides useful feedback, while its developing type system catches an increasing number of mistakes.

This contrasts with what I often see when agents work in JavaScript and Python projects. Strict types sit on top of those languages as optional layers, while their ecosystems contain many competing generations of tools and conventions. Agents mix ESM with CommonJS, use an old framework pattern beside a new one, hand-roll something the project already has, or create another implementation because they did not find the first one. Skills and prompts can reduce this, but they do not change the underlying substrate.

Then there is OTP. User sessions, background jobs, external API calls, and agent runs can all be represented as isolated processes with explicit ownership and supervision. One process can fail without taking the rest of the application with it. The running system is also directly inspectable: an agent can look at supervision trees, process state, message queues, application configuration, and database queries instead of trying to reconstruct everything from source code and logs.

José later described the same general direction in [“The future of coding agents is vertical integration”](https://tidewave.ai/blog/the-future-of-coding-agents-is-vertical-integration): an agent works much better when it can connect source code to the browser, logs, database, and running application instead of asking the developer to translate between them.

Elixir gave me a better foundation, but the scale at which agents could produce code created another problem: keeping that code coherent over time.

Agents tend to focus on the immediate task. They often fail to notice that a similar implementation already exists elsewhere, so they create another one. The copies then evolve separately: a bug is fixed in one but not the other, their behavior gradually diverges, and later agents add another variation because they cannot tell which one is canonical. This is one of the classic ways a vibe-coded codebase turns into a mess.

I started turning the checks I was performing during reviews into tools.

[ExAST](https://github.com/elixir-vibe/ex_ast) provides structural search and replacement for Elixir. Instead of grepping source text or inventing a regular expression, an agent can search for an actual Elixir syntax pattern and modify the matching AST.

For example, suppose an agent wants to combine a map-and-join pipeline into one operation:

```elixir
# Before: build an intermediate list, then join it.
Enum.map(names, &String.trim/1) |> Enum.join(", ")

# After: produce the joined string directly.
Enum.map_join(names, ", ", &String.trim/1)
```

ExAST can describe that change as a structural pattern and preview the replacements before anything is applied:

```elixir
plan = ExAST.rewrite_plan(
  source,
  "Enum.map(items, mapper) |> Enum.join(separator)",
  "Enum.map_join(items, separator, mapper)"
)
```

`items`, `mapper`, and `separator` capture expressions, not pieces of text. The same pattern works across line breaks and different variable names; a string containing the example is not a match. The plan exposes the original code, replacement, source range, and any conflicts for review. With the pure `String.trim/1` mapper, both versions return the same string; the replacement avoids the intermediate list. That does not make every matching rewrite safe: changing evaluation order still needs semantic review.

[ExDNA](https://github.com/elixir-vibe/ex_dna) detects duplicated code structurally. It can find exact and near-duplicate implementations even when variable names, literals, or surrounding syntax differ, and identify candidates for extraction into shared code. I use it with a zero-duplication budget in most of my projects.

[ExSlop](https://github.com/elixir-vibe/ex_slop) catches other recurring generated-code patterns that are not duplicates but often indicate that an agent ignored the language or the project’s existing abstractions.

These tools mostly see local structure. A function can look reasonable in isolation while creating a bad dependency, bypassing an architectural boundary, or allowing untrusted input to reach a database, filesystem, or shell command.

[Reach](https://github.com/elixir-vibe/reach) builds a program dependence graph: calls, control flow, data flow, effects, and OTP process relationships. It can render that structure as an interactive report or answer focused questions: what depends on this function, what a proposed change might affect, why one part of the system can reach another, and whether data can flow from a particular source to a dangerous effect.

Reach also turns architecture into something agents can check rather than something they are expected to remember. A project can declare its layers and forbidden dependencies, then reject changes that cross those boundaries. This gives an agent a view of the application that it cannot get by reading the current file and a few nearby imports.

But adding more checks creates its own risk. A false positive is annoying for a human, but an agent may obey it and make the code worse just to silence the warning. A rule that looks convincing in a few hand-written examples may fail on perfectly reasonable code in a real project.

That is why I built [Exograph](https://github.com/elixir-vibe/exograph). It can index the entire public Hex package ecosystem and combine structural ExAST queries with facts produced by Reach. I use that corpus to find false positives and decide whether a proposed rule is reliable enough to keep.

José Valim recently argued in [“Evolving programming languages in the AI era”](https://dashbit.co/blog/evolving-ai-era) that agents need stronger guarantees and a program database with a query language more than an editor protocol built for humans. Reach and Exograph are my attempt at that database for Elixir: facts about calls, data flow, effects, and architecture that an agent can query instead of reconstructing from files.

The same tools are used to check themselves. My projects combine the compiler, tests, Dialyzer, ExDNA, ExSlop, Reach, and architecture rules. [VibeKit](https://github.com/elixir-vibe/vibe_kit) packages the common setup so I can apply it consistently to new projects.

None of this makes blind vibe coding safe. It reduces some kinds of ambiguity, catches structural drift earlier, and gives agents more precise feedback when their work does not fit the rest of the system.

By then, I had a much better environment for agents working on the Elixir parts of an application. The frontend still lived in a separate runtime, toolchain, and ecosystem. That became the next problem.

## How the projects fit together

There are three useful layers to distinguish: the tools used to make a product, the environment that guides the work, and the infrastructure that runs it.

<.platform_layers />

The smaller examples below show individual connections. There is no need to understand every package before following the argument.

## Frontend tooling in Elixir

Choosing Elixir did not remove the need for JavaScript. The npm ecosystem contains too much useful work, and Vue is a good abstraction for building interfaces. Rewriting all of it in Elixir would make no sense.

The problem was not simply using JavaScript. It was putting the frontend in a separate operational world: Node processes, package managers, framework compilers, bundlers, CSS tools, and their own configuration and lifecycle.

I did not merely want Elixir to call JavaScript. That is easy: start a Node process and exchange JSON over stdin or HTTP. I wanted JavaScript execution to become observable and controllable as part of the same system.

That led to [QuickBEAM](https://github.com/elixir-volt/quickbeam).

In QuickBEAM, JavaScript runtimes and contexts behave like part of an OTP application. They have process ownership, participate in supervision trees, exchange messages with BEAM processes, and can be monitored, stopped, restarted, and inspected. JavaScript values map directly to BEAM terms rather than crossing a JSON boundary.

Execution can also be constrained by memory and reduction-style instruction budgets, so runaway JavaScript does not have unlimited control of the host application. Large numbers of lightweight contexts can share a small pool of runtime threads. Browser APIs such as workers, channels, timers, storage, networking, logging, and locks can be backed by OTP primitives.

JavaScript remains available where the ecosystem requires it, but it no longer disappears into an opaque Node sidecar.

The next missing part was package management. [`npm_ex`](https://github.com/elixir-volt/npm_ex) can resolve, fetch, cache, and install npm packages from Elixir. It started as a small library for inspecting `package.json` and dependency trees, then grew into most of a package manager.

I also created Elixir bindings for the Rust tools that already do much of the real work in modern frontend toolchains: OXC for JavaScript and TypeScript, Vize for Vue, and Tailwind’s Oxide scanner. These projects did not need to be rewritten; they needed APIs the BEAM could call directly.

[Volt](https://github.com/elixir-volt/volt) assembles these pieces into one frontend toolchain. It provides a development server, HMR, compilation, Tailwind, linting, testing, and production builds for JavaScript, TypeScript, Vue, React, Svelte, and Solid. The toolchain starts with the application and can be configured, observed, and extended from Elixir.

<figure class="not-prose my-10 border-y border-copy/25 py-6">
  <figcaption class="mb-4 text-sm text-dim">The frontend path, with Volt owning the toolchain.</figcaption>
  <ol class="grid gap-4 sm:grid-cols-3">
    <li><strong class="block">1. Author</strong><span>TypeScript, Vue components, and CSS.</span></li>
    <li><strong class="block">2. Build</strong><span>OXC, Vize, and Tailwind, coordinated from Elixir.</span></li>
    <li><strong class="block">3. Run</strong><span>Browser assets, with HMR during development.</span></li>
  </ol>
</figure>

This removes one boundary, but frontend and backend code can still describe two halves of the same behavior and quietly disagree.

[PhoenixVapor](https://github.com/elixir-volt/phoenix_vapor) explores a more direct bridge. It compiles Vue template syntax into native Phoenix LiveView rendering structures. It supports several modes: Vue syntax with no client JavaScript, server-side reactivity through QuickBEAM, or a hybrid where the server owns application data while the browser owns local interface state.

This connects back to VuePencil. A component created there can remain a real Vue component. It can become an ordinary client-side Vue application built by Volt, a Vue island inside a Phoenix application, or a template compiled into LiveView rather than being reconstructed from a separate mockup.

## The coding environment

I am a big fan of [Pi](https://github.com/badlogic/pi-mono) for its simplicity, minimalism, and extensibility. Its core is deliberately small, while extensions, skills, and prompt files let me adapt it to my workflow. That is why I initially built [pi-elixir](https://github.com/elixir-vibe/pi-elixir) as a Pi extension instead of starting another coding agent.

pi-elixir connects Pi to the BEAM. It lets the agent evaluate Elixir inside the project or a running application, inspect OTP and Ecto state, use ExAST for structural code work, and keep values between calls like an IEx or Livebook session. The agent can ask the running system what is happening instead of reconstructing it from files and logs.

But the more I extended the harness, the less natural its underlying execution model felt for the direction I wanted to take.

A coding harness is a concurrent, long-running system. It coordinates model streams, terminal input, tool execution, background work, cancellation, retries, persistence, and eventually other agents. JavaScript can implement all of this, and Pi implements it carefully. But the work still travels through layers of promises, async iterators, event handlers, callbacks, and terminal redraws inside one process. Ownership and failure boundaries are maintained by convention, and synchronous work in one place can delay unrelated streams and input.

OTP has a more direct model for this. A session can be a process. A model request and each tool execution can be supervised children. Terminal, browser, persistence, and remote clients can observe the session without owning it. Processes can be monitored, cancelled, restarted, or allowed to fail independently. Ordinary BEAM code is preemptively scheduled according to reductions instead of relying on every task to yield voluntarily.

I built [Vibe](https://github.com/elixir-vibe/vibe) to explore this architecture without the constraints of an existing harness.

In Vibe, sessions, agents, subagents, commands, and interfaces are OTP processes. Agents can start other agents and communicate through messages. They can run on one node or communicate across machines through Erlang distribution and SSH. Closing a terminal does not have to stop the work, and a failing subagent does not have to destroy its parent session.

This is not only my intuition about a suitable runtime. OpenAI made a similar choice for the reference implementation of [Symphony](https://github.com/openai/symphony), its system for supervising long-running coding-agent work.

Vibe is useful, but it is also an experiment. I do not want to force users to replace a mature harness with my half-finished one just to test each hypothesis. When an idea works in Vibe, I can bring it back into pi-elixir and test it inside Pi. The newer pi-elixir combines Pi’s model support, interface, and extension system with more of the BEAM-native runtime and structural tooling explored in Vibe.

[Tilde](https://github.com/elixir-vibe/tilde) develops another part of this architecture: separating an agent session from any particular interface.

A Tilde session is a stream of semantic events: a message was added, a tool started, output arrived, a choice was requested, or an agent completed its work. The same session can be rendered in a terminal, in a browser with LiveView, over SSH, or as structured data. ANSI terminal cells and browser DOM are outputs, not the authoritative state.

Vibe and Tilde are steps toward a cleaner architecture for agents that can communicate locally or over a network. pi-elixir is how I test the useful parts of that architecture today without abandoning Pi.

The next problem was giving this environment common access to storage, models, and external services.

## Common storage and APIs

A platform for building several products should not require a separate collection of managed services for each one. I wanted the default setup to remain cheap, portable, and easy to run locally.

For storage, I settled on DuckDB.

DuckDB combines much of the SQL surface I expect from PostgreSQL with the portability of SQLite. A complete database can live in one file, but it still supports analytical queries, full-text search, geospatial operations, Parquet, direct access to S3, and a growing ecosystem of extensions. For many small and medium products, it can handle both ordinary application data and serious analytics without requiring a separate analytical cluster.

[QuackDB](https://github.com/elixir-vibe/quackdb) makes DuckDB usable as part of an Elixir application. It provides an OTP-supervised DuckDB process, a `DBConnection` client, an Ecto adapter, streaming and native append APIs, and integrations with Explorer and geospatial data.

DuckDB is becoming the common storage layer across the platform: application records, agent sessions, code indexes, analytics, traces, and other operational data can use the same portable foundation.

I started QuackDB while DuckDB’s Quack client-server protocol was still experimental, but the situation has changed quickly. In [DuckDB 2.0 alpha](https://duckdb.org/2026/09/02/try-duckdb-20-alpha.html), the Quack extension is moving from 0.x to 1.0, with higher query throughput and better compatibility. Amazon has also [signed an agreement to acquire DuckLabs](https://aws.amazon.com/blogs/big-data/aws-and-ducklabs-building-the-future-of-analytics-together/). DuckDB’s creators will continue leading its technical direction, while the project remains under the independent DuckDB Foundation and the MIT license. I consider DuckDB a strong long-term bet.

Storage was only one source of fragmentation. Not every product needs an LLM, but model access has become a common requirement, and almost every product eventually depends on external APIs.

[LLMProxy](https://github.com/elixir-vibe/llm_proxy) provides one execution path for model calls. It handles provider routing, fallback models, credential pools, quotas, usage accounting, tracing, and cost. It can run inside an Elixir application or expose OpenAI- and Anthropic-compatible HTTP APIs for other clients.

This means the application and its agents do not each need their own provider integrations and accounting. Model selection can change without rewriting every caller, and the founder can see where tokens are being spent across products and agents.

I found the same pattern repeated with non-LLM services. A startup gradually accumulates APIs for email, advertising, payments, image generation, vectorization, search, hosting, and many other tasks. Each integration comes with its own authentication, retries, limits, credentials, errors, and accounting.

[Egress](https://github.com/elixir-vibe/egress) generalizes the approach I started with LLMProxy. An external service is described once as a set of typed operations. The same definition can produce an Elixir client or a standalone proxy route, while calls pass through one runtime path for authentication, retries, quotas, routing, tracing, and accounting.

The important unit is not an HTTP URL, but an operation such as `create_campaign`, `send_email`, or `vectorize_image`. Agents should work with those operations and their contracts rather than constructing arbitrary requests and learning every provider’s authentication scheme.

There will also be more conventional application building blocks: authentication and authorization, accounts, files, notifications, realtime features, billing, and the other things for which founders currently reach for Supabase or libraries such as Better Auth. I do not intend to rebuild everything unnecessarily. The goal is to provide coherent Elixir APIs and defaults, using existing projects where they fit and filling gaps where they do not.

## Deployment without another platform

Once the application is built, it still has to run somewhere.

For small products, deployment often introduces another large stack: container registries, orchestration, managed databases, queues, proxies, secret stores, and several dashboards. These tools can be justified at a certain scale, but I do not want every experiment to begin with them.

Elixir already has a good deployment unit: an OTP release containing the application, its dependencies, and the runtime it needs.

[ReleaseKit](https://github.com/elixir-vibe/release_kit) turns a Mix release into a repeatable, deployment-neutral artifact. It produces an ordinary tarball and a small manifest describing how to run it, which environment it expects, and how to check its health. It deliberately knows nothing about servers, users, systemd, or reverse proxies.

[HostKit](https://github.com/elixir-vibe/host_kit) handles the other half. It describes a Linux host in Elixir: packages, users, directories, configuration files, secrets, services, timers, firewall rules, and Caddy routes. It reads the current state, produces a plan, and applies the reviewed plan locally or over SSH.

The result is based on ordinary Linux components. Services run under systemd with restart policies, resource limits, filesystem restrictions, and network isolation. HostKit can bootstrap an empty machine, so the target does not need Elixir, Mix, Docker, or the application runtime installed in advance.

HostKit is a library first; its Mix tasks are wrappers around normal Elixir APIs. The desired host state, current state, plan, apply process, health checks, drift, host facts, and rollback operations are all programmatically accessible.

An agent therefore sees infrastructure as another part of the system rather than an opaque deployment script. It can inspect listening ports and failed services, audit declared resources, compare configuration, explain a plan before applying it, verify the result, and propose or perform a rollback through the same Elixir environment it uses for code and runtime state.

HostKit is still a beta, but I already use it on my own infrastructure. The purpose is not to replace every cloud platform. It is to make deploying a small or medium product cheap and understandable, while keeping infrastructure as observable and controllable by agents as every other component of the platform.

Once the product is running, the more interesting question begins: what are users actually doing, where did they come from, what is breaking, and what should change next?

## From analytics to the next decision

The answers are usually divided among unrelated systems. Advertising platforms know the campaign and its cost. Web analytics knows the landing page and conversion. Session-recording software knows what happened in the browser. Application monitoring has the errors and traces. The BEAM knows the live process state. An LLM provider knows how many tokens were spent. None of them has the complete context.

I started experimenting with this in a fork of [Plausible Analytics](https://github.com/dannote/analytics). I am porting its analytics storage to DuckDB through QuackDB. The goal is to keep traffic, funnels, attribution, conversions, and other product analytics in the same portable data layer as the rest of the platform, without requiring separate managed PostgreSQL and ClickHouse instances for every product.

Aggregate analytics still cannot explain what happened to one particular user. For that, I built [PhoenixReplay](https://github.com/elixir-vibe/phoenix_replay).

In a Phoenix LiveView application, much of the interface state lives on the backend. The browser displays updates produced from that state. This creates an unusual opportunity: instead of recording only clicks and DOM changes in the browser, PhoenixReplay can record the backend state and use it to recreate what the user saw. We can replay both sides of the session: the frontend experience and the backend state that produced it.

The next step is to connect these sources rather than open them in separate dashboards.

Suppose a customer arrives through a paid campaign, begins registration, gets stuck, and leaves. I want to see where they came from and how much that acquisition cost, replay what they experienced in the browser together with the corresponding backend state, inspect related errors and traces, and follow the relevant code path. If an LLM or another paid API participated in the request, its latency and cost should be visible too.

[Incant](https://github.com/elixir-vibe/incant) is the common admin interface I am building for this. It is intended to show ordinary application records, analytical datasets, campaign performance, replay sessions, telemetry, LLM traces, agent state, infrastructure, and other operational data through the same set of Elixir APIs.

This is useful not only for the founder. An agent can query the same data and correlate it across subsystems. A background agent could notice that conversion from a campaign dropped, identify the affected landing page, inspect recent sessions, find where users started abandoning the funnel, and suggest a next step with the evidence that led to it.

The important part is that these should be motivated suggestions, not unexplained autonomous decisions. An agent may propose changing a bid, pausing a campaign, investigating a slow request, or modifying a signup step. The founder can inspect the reasoning and approve the action.

<figure class="not-prose my-10 border-y border-copy/25 py-6">
  <figcaption class="mb-5 text-sm text-dim">The intended feedback loop — evidence first, approval before action.</figcaption>
  <ol class="grid gap-5 sm:grid-cols-2">
    <li><strong class="block">1. Observe</strong>Conversions, session recordings, errors, and costs.</li>
    <li><strong class="block">2. Investigate</strong>Connect the user’s experience to runtime state and code.</li>
    <li><strong class="block">3. Decide</strong>Review the evidence and approve a proposed change.</li>
    <li><strong class="block">4. Measure again</strong>Check whether the change helped; return to observation.</li>
  </ol>
</figure>

## How this differs from Lovable and Replit

Lovable and Replit concentrate mainly on turning a prompt into a working and deployed application. I am trying to cover a larger part of the founder’s work: exploring several design directions, building the application, checking how it evolves, operating it, acquiring users, understanding their behavior, and feeding that evidence into the next decision.

The technical foundation is different too. Skills can improve an agent working on a JavaScript or Python project, but they cannot change the execution model or remove the conflicting conventions the agent has learned from those ecosystems. My approach uses Elixir and OTP as the common environment, then adds structural code analysis, observable JavaScript execution, shared storage, deployment APIs, and access to live product data.

People tend to build for the conditions they know. Lovable and Replit grew out of venture-capital culture, where rapid user growth can take priority over margins and usage can be subsidized while a company searches for scale. I am building from the perspective of a technical founder spending his own money. Infrastructure cost, API usage, acquisition cost, conversion, and the work required to operate the product are part of the system from the beginning.

## What exists today

These examples describe the system I am building, not a finished product that can already be installed with one command.

Most of the building blocks are public and useful independently. OpenPencil already ships as a desktop and web editor, CLI, MCP server, and Vue SDK. The analysis and frontend packages are published and used in real projects. The agent, storage, service, deployment, replay, and admin layers exist at different levels of maturity.

VuePencil remains a prototype. Tilde and Egress are early. The DuckDB-backed analytics work is not finished, and Incant does not yet connect all of these sources.

The main missing piece is integration. These projects already use one another—Volt uses QuickBEAM, Exograph uses QuackDB and ExAST, HostKit consumes ReleaseKit artifacts, and my projects run the quality tools on themselves—but they do not yet form one coherent founder-facing product.

All of this started as a one-person effort. Agents let me cover a surprising amount of ground, but they cannot provide the variety of real-world use that a community can. By publishing each building block separately, I let people test it with files, applications, operating systems, and workflows I could not anticipate. Their bug reports expose my assumptions, and their contributions take the projects beyond my own needs. Open source is not only how I distribute the platform; it is part of how I develop it.

## What comes next

I have spent most of this year building and extracting the missing parts. The next phase is less about adding more unrelated foundations and more about connecting what already exists.

The most immediate product is OpenPencil Cloud: optional workspaces, synchronization, sharing, comments, collaboration, and team component libraries. Local files will remain first-class, and the backend will also be self-hostable.

I also want to turn reference collection, alternative drafts, comparison, and iterative work with virtual designers into one coherent OpenPencil workflow. A related service may provide common access to language and vision models, image generation, vectorization, SVG generation, and other design APIs—something like OpenRouter focused on design—while continuing to support users’ own credentials.

The path through VuePencil, the coding environment, and the rest of the platform then needs to become a product rather than a diagram. That includes filling conventional gaps such as authentication and file storage, and connecting Incant to the operational sources that already exist.

Not every part will follow the current plan exactly. Some packages will merge, some abstractions will change after real use, and some experiments may fail. Publishing the pieces independently is how I expect to find that out.

## How to help

This is still mostly a one-person effort, and there are more useful directions than I can pursue at once. The best way to help is to use the projects in situations I have not considered, report what breaks, and tell me which parts are useful outside my own workflow. Contributions are welcome too.

Until now, I have paid for the development and infrastructure myself. I am beginning to look for sponsors, grants, infrastructure partners, and companies interested in supporting particular parts of the work. I am also preparing OpenPencil Cloud as the first commercial service around the open-source projects.

If you use any of these tools, want to contribute, or represent an organization interested in supporting the work, please contact me at [hello@dannote.net](mailto:hello@dannote.net).
