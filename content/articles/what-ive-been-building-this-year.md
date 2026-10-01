---
title: "What I’ve been building this year"
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

There is a Figma-compatible design editor, a JavaScript runtime for the [BEAM](https://en.wikipedia.org/wiki/BEAM_%28Erlang_virtual_machine%29), a frontend build tool, an npm client, several static analyzers, coding-agent tools, a [DuckDB](https://duckdb.org) adapter, session replay, deployment tooling, and many smaller libraries in between.

Judging by my feed, it probably looks like I wake up every few days with an unrelated idea, build it, publish it, and move on to the next one.

That is partly my fault. I have explained each project when I released it, but I have never properly explained how they fit together.

They are all parts of the same system.

## TL;DR

I am building an end-to-end open-source platform for startup factories. By a startup factory I mean a venture studio: a small team, often one technical founder working with agents, that launches many products, keeps the ones that work, and kills the rest. The platform follows each product through its whole lifecycle, from references and design drafts through prototypes, code, deployment, and acquisition, to the evidence that decides what to build next.

The process starts in [OpenPencil](https://github.com/open-pencil/open-pencil), a design editor where the founder works with an agent the way they would stand behind a product designer: describing what is in their head, watching drafts appear, and steering until the design on the canvas matches the idea. Selected designs become working [Vue](https://vuejs.org) components. The product then moves into an [Elixir](https://elixir-lang.org) environment that connects coding, deployment, and operation, so a coding agent can see the whole product rather than one repository or one error log. If a customer gets stuck, the system can trace where they came from, replay what they experienced in the browser and on the backend, inspect the code path, and propose a next step with evidence.

My ambition is an open-source vibe-coding platform that can eventually compete with [Figma](https://www.figma.com), [Lovable](https://lovable.dev), and [Replit](https://replit.com), designed around technical founders like me.

<.project_map />

The rest of this post walks through the map in the order I built it.

## Who I am

I am a programmer, but I have never stayed in one narrow part of the stack. I have done systems programming, contributed to open source in the [Xfce](https://gitlab.xfce.org/xfce/garcon/-/commit/aec77533132eb324180ef771e15226a752573eae) and [nginx](https://github.com/dannote/socks-nginx-module) ecosystems, done white-hat security research through [Google Bug Hunters](https://bughunters.google.com/profile/62602ae8-cf92-4fb0-810c-c9e284f3427e) and [Bugcrowd](https://bugcrowd.com/h/dannote), built web applications, and occasionally worked as a designer. I tend to move to whichever layer contains the problem.

I have also spent a long time working in venture studios, and I have founded and run small companies with my own money.

That made the economics impossible for me to separate from product development. A percentage point of conversion can determine whether a campaign is profitable. Customer acquisition cost, margins, infrastructure, API usage, and the time required to operate a product all affect what to build next and when to stop.

The first part of that process I tried to improve was design.

## It started with Figma

[OpenPencil](https://github.com/open-pencil/open-pencil) did not begin as an attempt to build a Figma competitor.

I created [`figma-use`](https://github.com/dannote/figma-use) to automate repetitive work in Figma. I wanted to inspect layers, make bulk changes, generate component structures, and export assets without clicking through the interface every time.

Figma had already released an [MCP](https://modelcontextprotocol.io) server, but it was not capable of even basic editing. It could expose the canvas to an agent as something close to a node-tree dump, but the agent could not meaningfully work with it.

Coding agents did not become useful only because the underlying models became smarter. They became useful because the harnesses around them, the tools that wrap a model in a loop, enabled an iterative process. An agent can inspect a repository, make a change, run the application, read an error, look at the result, compare it with what was expected, and try again.

I wanted to give design agents the same kind of loop.

Good design is iterative too. A designer normally begins by collecting references, then draws several drafts, compares them, and chooses a direction. After that comes a longer loop: copy, tweak, compare, choose, and repeat. The first result is rarely the final one.

Most AI design tools ignore this process. They try to generate a finished screen in one shot. Even when the screenshot looks impressive, the structure underneath is often useless: unnamed nested frames, no components, no tokens, and no coherent system that another designer can continue working with.

With [`figma-use`](https://github.com/dannote/figma-use), an agent could work on the actual structure. It could create and modify nodes, use components and variants, describe a screen in JSX and render it as Figma layers, inspect the resulting tree, and continue from there. I added visual diffing so it could see what changed, and design linting so it could catch structural and accessibility problems. I also wanted design files in automated pipelines: linted in CI, compared between revisions, and exported without anybody opening Figma.

Then Figma released an update that blocked the debugging interface [`figma-use`](https://github.com/dannote/figma-use) relied on.

I found workarounds and kept the tool working, but the larger lesson was obvious. I could not build this kind of infrastructure on access that a vendor could remove at any moment. If agents were going to treat design as a real programmable medium, the editor itself had to be open.

The official route is not much safer. Figma's remote MCP server now decides which agents may connect at all: sign-in works only for client names on its list, such as Claude Code or Codex. When Mario Zechner tried to connect [Pi](https://github.com/badlogic/pi-mono), his open-source coding agent, Figma refused it because [Pi](https://github.com/badlogic/pi-mono) identifies itself as `pi`.

> today in MCP land ...
>
> thing are better compared to a year ago, but also worse.
>
> ![A message: I'm trying to connect to Figma's remote MCP server. Figma only accepts certain client names during sign-in, e.g., Claude Code or Codex, but Pi 0.99.1 always sends pi.](images/x/badlogicgames-2105234146499203255.png)
>
> — Mario Zechner (@badlogicgames), [30 September 2026](https://x.com/badlogicgames/status/2105234146499203255)

That is how [OpenPencil](https://github.com/open-pencil/open-pencil) began.

## OpenPencil became a toolkit

[OpenPencil](https://github.com/open-pencil/open-pencil) initially gave me an independent environment for the work I had started with [`figma-use`](https://github.com/dannote/figma-use). It could open and write `.fig` files, render them without Figma, and let agents modify the actual document structure.

While refactoring the project, I realized that the editor itself should not be the only useful result. I split the monolith into reusable parts: the `.fig` parser, the [Kiwi](https://github.com/evanw/kiwi) parser for the binary format inside those files, the scene graph, editor core, CLI, MCP server, and headless Vue SDK. The [OpenPencil](https://github.com/open-pencil/open-pencil) application is now one consumer of these packages.

The Vue SDK lets developers construct a different editor shell around the same engine. They can embed an editing surface into their product, expose a restricted editor for a particular workflow, or add design tools to an IDE without forking the [OpenPencil](https://github.com/open-pencil/open-pencil) interface.

The engine does not require an editor UI at all. A script or CI job can query a `.fig` file, lint it, extract tokens, convert it, render it, compare it with another revision, or modify it through the same operations used by the application and its agents.

My goal is to make `.fig` a commodity. If independent software can parse, query, render, modify, and convert the format, it stops being something that can only be fully used inside Figma. It becomes input for other editors, IDEs, and automated pipelines.

This solves access to the design structure, but not the boundary between a design and the application eventually built from it.

## From designs to real components

The next direction I started exploring is [VuePencil](https://github.com/dannote/vue-pencil): something like Figma, but for Vue components.

Many visual HTML builders have an abstraction problem. The editor is already an HTML application, and then it tries to build another HTML application inside itself. The layers gradually leak into each other. The tool either supports only a restricted subset of HTML and becomes brittle, or exposes more and more browser internals until it turns into a complicated version of developer tools.

Vue already has a suitable abstraction for this: the VNode tree, its in-memory description of what it renders. In [VuePencil](https://github.com/dannote/vue-pencil), that tree is the source of truth. Editor operations change the model, Vue renders it, and the editor reads the resulting geometry to position selections and handles. It does not directly rewrite the rendered DOM.

This also means that the things placed on the canvas can be real components. The current prototype supports [Reka UI](https://reka-ui.com) primitives, component parts, named slots, props, bindings, and [VueUse](https://vueuse.org) composables. A switch on the canvas is the real component, and it works in preview mode:

```vue
<SwitchRoot v-model="enabled">
  <SwitchThumb />
</SwitchRoot>
```

The result can be serialized as a normal Vue [SFC](https://vuejs.org/guide/scaling-up/sfc.html). Frames and canvas positions remain editor metadata rather than leaking into component CSS. Slots become Vue slots, capabilities become composable calls, and bindings become ordinary Vue expressions.

This makes prototypes much more useful than links between static screens. A founder can continue the design process with working state and interactions, then take the resulting components into the coding environment instead of asking an agent to reconstruct them from a separate design. [VuePencil](https://github.com/dannote/vue-pencil) is still an early experiment, but it shows how [OpenPencil](https://github.com/open-pencil/open-pencil) can evolve beyond Figma compatibility without turning into an HTML builder.

## Why Elixir?

Once the prototype becomes a real application, design is only one part of the problem. You need a backend, storage, background jobs, external APIs, deployment, analytics, and a way for agents to work with all of them.

For mathematics there is [Lean](https://lean-lang.org). Every definition, theorem, and proof is written in one language and checked by one small, trusted kernel. A model trained on Lean does not spend capacity learning five notations for the same idea, and every step it takes gets a verdict. My bet is that this is why such models reason so densely.

I want the same for the web stack. Not one language that replaces JavaScript, Rust, and SQL. One language in which bundling, the JavaScript runtime, storage, the backend, deployment, and operations have the same kind of API, run in the same runtime, and are checked by the same tools. Elixir is the closest thing I found, and the rest of this post is what it took to make that true. I first wrote about this intuition in [“A language for humans and models”](/writing/a-language-for-humans-and-models/).

I was initially skeptical when José Valim, the creator of Elixir, published [“Why Elixir is the best language for AI”](https://dashbit.co/blog/why-elixir-best-language-for-ai). He referred to [AutoCodeBench](https://autocodebench.github.io/), where Elixir had the highest completion rate across 20 languages. The benchmark was interesting, but his explanation mattered more: immutability makes local reasoning easier, documentation examples are often verified by tests, and the ecosystem has remained stable enough that models encounter fewer generations of conflicting APIs.

After using agents to build more and more Elixir code, I started to agree.

Elixir is dynamic too, so this is not a simple comparison between typed and untyped languages. But data flow is usually explicit, pattern matching exposes many contracts directly in the code, and the language has relatively consistent conventions. The compiler provides useful feedback, while its developing type system catches an increasing number of mistakes.

This contrasts with what I often see when agents work in JavaScript and Python projects. Strict types sit on top of those languages as optional layers, while their ecosystems contain many competing generations of tools and conventions. Agents mix ESM with CommonJS, use an old framework pattern beside a new one, hand-roll something the project already has, or create another implementation because they did not find the first one. Skills and prompts can reduce this, but they do not change the underlying substrate.

Then there is [OTP](https://www.erlang.org/doc/system/design_principles.html), the framework of processes and supervisors that Elixir inherits from Erlang. User sessions, background jobs, external API calls, and agent runs can all be represented as isolated processes with explicit ownership and supervision. One process can fail without taking the rest of the application with it. The running system is also directly inspectable: an agent can look at supervision trees, process state, message queues, application configuration, and database queries instead of trying to reconstruct everything from source code and logs.

José later described the same general direction in [“The future of coding agents is vertical integration”](https://tidewave.ai/blog/the-future-of-coding-agents-is-vertical-integration): an agent works much better when it can connect source code to the browser, logs, database, and running application instead of asking the developer to translate between them.

## Checking what agents write

Lean is only half notation. The other half is the kernel, which tells the model whether each step holds. Elixir's compiler, [Dialyzer](https://www.erlang.org/doc/apps/dialyzer/dialyzer.html), and tests are a start, but the scale at which agents produce code created a problem none of them catch: keeping that code coherent over time.

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

[ExAST](https://github.com/elixir-vibe/ex_ast) can describe that change as a structural pattern and preview the replacements before anything is applied:

```elixir
plan = ExAST.rewrite_plan(
  source,
  "Enum.map(items, mapper) |> Enum.join(separator)",
  "Enum.map_join(items, separator, mapper)"
)
```

`items`, `mapper`, and `separator` capture expressions, not text, so the pattern matches across line breaks and variable names, and a string containing the example does not. The plan exposes the original code, the replacement, the source range, and any conflicts for review. It is a proposal, not proof that the rewrite is safe: [ExAST](https://github.com/elixir-vibe/ex_ast) knows structure, not semantics.

[ExDNA](https://github.com/elixir-vibe/ex_dna) detects duplicated code structurally. It can find exact and near-duplicate implementations even when variable names, literals, or surrounding syntax differ, and identify candidates for extraction into shared code. I use it with a zero-duplication budget in most of my projects.

[ExSlop](https://github.com/elixir-vibe/ex_slop) catches other recurring generated-code patterns that are not duplicates but often indicate that an agent ignored the language or the project’s existing abstractions.

These tools mostly see local structure. A function can look reasonable in isolation while creating a bad dependency, bypassing an architectural boundary, or allowing untrusted input to reach a database, filesystem, or shell command.

[Reach](https://github.com/elixir-vibe/reach) builds a program dependence graph: calls, control flow, data flow, effects, and OTP process relationships. It can render that structure as an interactive report or answer focused questions: what depends on this function, what a proposed change might affect, why one part of the system can reach another, and whether data can flow from a particular source to a dangerous effect.

[Reach](https://github.com/elixir-vibe/reach) also turns architecture into something agents can check rather than something they are expected to remember. A project can declare its layers and forbidden dependencies, then reject changes that cross those boundaries. This gives an agent a view of the application that it cannot get by reading the current file and a few nearby imports.

But adding more checks creates its own risk. A false positive is annoying for a human, but an agent may obey it and make the code worse just to silence the warning. A rule that looks convincing in a few hand-written examples may fail on perfectly reasonable code in a real project.

That is why I built [Exograph](https://github.com/elixir-vibe/exograph). It can index the entire public [Hex](https://hex.pm) package ecosystem and combine structural [ExAST](https://github.com/elixir-vibe/ex_ast) queries with facts produced by [Reach](https://github.com/elixir-vibe/reach). I use that corpus to find false positives and decide whether a proposed rule is reliable enough to keep.

José Valim recently argued in [“Evolving programming languages in the AI era”](https://dashbit.co/blog/evolving-ai-era) that agents need stronger guarantees and a program database with a query language more than an editor protocol built for humans. [Reach](https://github.com/elixir-vibe/reach) and [Exograph](https://github.com/elixir-vibe/exograph) are my attempt at that database for Elixir: facts about calls, data flow, effects, and architecture that an agent can query instead of reconstructing from files.

The same tools are used to check themselves. My projects combine the compiler, tests, Dialyzer, [ExDNA](https://github.com/elixir-vibe/ex_dna), [ExSlop](https://github.com/elixir-vibe/ex_slop), [Reach](https://github.com/elixir-vibe/reach), and architecture rules. [VibeKit](https://github.com/elixir-vibe/vibe_kit) packages the common setup so I can apply it consistently to new projects.

None of this makes blind vibe coding safe. It reduces some kinds of ambiguity, catches structural drift earlier, and gives agents more precise feedback when their work does not fit the rest of the system.

## Frontend tooling in Elixir

Choosing Elixir did not remove the need for JavaScript. The npm ecosystem contains too much useful work, and Vue is a good abstraction for building interfaces. Rewriting all of it in Elixir would make no sense.

The problem was the separate operational world around it: Node processes, package managers, framework compilers, bundlers, and CSS tools, each with its own configuration and lifecycle. Calling JavaScript from Elixir is easy; start a Node process and exchange JSON. I wanted JavaScript execution to be observable and controllable as part of the same system.

That led to [QuickBEAM](https://github.com/elixir-volt/quickbeam).

In [QuickBEAM](https://github.com/elixir-volt/quickbeam), JavaScript runtimes and contexts behave like part of an OTP application. They have process ownership, participate in supervision trees, exchange messages with BEAM processes, and can be monitored, stopped, restarted, and inspected. JavaScript values map directly to BEAM terms rather than crossing a JSON boundary.

Execution can also be constrained by memory and instruction budgets, counted in reductions like any BEAM process, so runaway JavaScript does not have unlimited control of the host application. Large numbers of lightweight contexts can share a small pool of runtime threads. Browser APIs such as workers, timers, storage, and networking can be backed by OTP primitives.

JavaScript remains available where the ecosystem requires it, but it no longer disappears into an opaque Node sidecar.

Package management came next. [`npm_ex`](https://github.com/elixir-volt/npm_ex) can resolve, fetch, cache, and install npm packages from Elixir. It started as a small library for inspecting `package.json` and dependency trees, then grew into most of a package manager.

I also created Elixir bindings for the Rust tools that already do much of the real work in modern frontend toolchains: [OXC](https://oxc.rs) for JavaScript and TypeScript, [Vize](https://github.com/ubugeeei/vize) for Vue, and [Tailwind](https://tailwindcss.com)’s Oxide scanner, which finds class names in source files. These projects did not need to be rewritten; they needed APIs the BEAM could call directly.

[Volt](https://github.com/elixir-volt/volt) assembles these pieces into one frontend toolchain: a development server with hot module replacement, Tailwind, linting, tests, and production builds for TypeScript, Vue, React, Svelte, and Solid. The toolchain starts with the application and can be configured, observed, and extended from Elixir.

<.volt_tree />

This removes one boundary, but frontend and backend code can still describe two halves of the same behavior and quietly disagree.

[PhoenixVapor](https://github.com/elixir-volt/phoenix_vapor) explores a more direct bridge. It compiles Vue template syntax into native [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view) rendering structures. It supports several modes: Vue syntax with no client JavaScript, server-side reactivity through [QuickBEAM](https://github.com/elixir-volt/quickbeam), or a hybrid where the server owns application data while the browser owns local interface state.

This connects back to [VuePencil](https://github.com/dannote/vue-pencil). A component created there can remain a real Vue component. It can become an ordinary client-side Vue application built by [Volt](https://github.com/elixir-volt/volt), a Vue island embedded in a server-rendered [Phoenix](https://www.phoenixframework.org) page, or a template compiled into LiveView rather than being reconstructed from a separate mockup.

## The coding environment

I am a big fan of [Pi](https://github.com/badlogic/pi-mono), the coding agent Figma turned away earlier in this post, for its simplicity, minimalism, and extensibility. Its core is deliberately small, while extensions, skills, and prompt files let me adapt it to my workflow. That is why I initially built [pi-elixir](https://github.com/elixir-vibe/pi-elixir) as a [Pi](https://github.com/badlogic/pi-mono) extension instead of starting another coding agent.

[pi-elixir](https://github.com/elixir-vibe/pi-elixir) connects [Pi](https://github.com/badlogic/pi-mono) to the BEAM. It lets the agent evaluate Elixir inside the project or a running application, inspect OTP and [Ecto](https://hexdocs.pm/ecto) state, use [ExAST](https://github.com/elixir-vibe/ex_ast) for structural code work, and keep values between calls like an IEx or [Livebook](https://livebook.dev) session.

But the more I extended the harness, the less natural its underlying execution model felt for the direction I wanted to take.

A coding harness is a concurrent, long-running system. It coordinates model streams, terminal input, tool execution, background work, cancellation, retries, persistence, and eventually other agents. JavaScript can implement all of this, and [Pi](https://github.com/badlogic/pi-mono) implements it carefully. But the work still travels through layers of promises, async iterators, event handlers, callbacks, and terminal redraws inside one process. Ownership and failure boundaries are maintained by convention, and synchronous work in one place can delay unrelated streams and input.

OTP has a more direct model for this. A session can be a process. A model request and each tool execution can be supervised children. Terminal, browser, persistence, and remote clients can observe the session without owning it. Processes can be monitored, cancelled, restarted, or allowed to fail independently. Ordinary BEAM code is preemptively scheduled according to reductions instead of relying on every task to yield voluntarily.

I built [Vibe](https://github.com/elixir-vibe/vibe) to explore this architecture without the constraints of an existing harness.

In [Vibe](https://github.com/elixir-vibe/vibe), sessions, agents, subagents, commands, and interfaces are OTP processes. Agents can start other agents and communicate through messages. They can run on one node or communicate across machines through Erlang distribution and SSH. Closing a terminal does not have to stop the work, and a failing subagent does not have to destroy its parent session.

<.vibe_tree />

OpenAI reached the same conclusion from the other direction. The reference implementation of [Symphony](https://github.com/openai/symphony), its system for supervising long-running coding-agent work, is written in Elixir.

[Vibe](https://github.com/elixir-vibe/vibe) is useful, but it is also an experiment. I do not want to force users to replace a mature harness with my half-finished one just to test each hypothesis. When an idea works in [Vibe](https://github.com/elixir-vibe/vibe), I can bring it back into [pi-elixir](https://github.com/elixir-vibe/pi-elixir) and test it inside [Pi](https://github.com/badlogic/pi-mono). The newer [pi-elixir](https://github.com/elixir-vibe/pi-elixir) combines [Pi](https://github.com/badlogic/pi-mono)’s model support, interface, and extension system with more of the BEAM-native runtime and structural tooling explored in [Vibe](https://github.com/elixir-vibe/vibe).

[Tilde](https://github.com/elixir-vibe/tilde) develops another part of this architecture: separating an agent session from any particular interface.

A [Tilde](https://github.com/elixir-vibe/tilde) session is a stream of semantic events: a message was added, a tool started, output arrived, a choice was requested, or an agent completed its work. The same session can be rendered in a terminal, in a browser with LiveView, over SSH, or as structured data. ANSI terminal cells and browser DOM are outputs, not the authoritative state.

[Vibe](https://github.com/elixir-vibe/vibe) and [Tilde](https://github.com/elixir-vibe/tilde) are steps toward a cleaner architecture for agents that can communicate locally or over a network. [pi-elixir](https://github.com/elixir-vibe/pi-elixir) is how I test the useful parts of that architecture today without abandoning [Pi](https://github.com/badlogic/pi-mono).

## Common storage and APIs

A platform for building several products should not require a separate collection of managed services for each one. I wanted the default setup to remain cheap, portable, and easy to run locally.

For storage, I settled on DuckDB.

DuckDB combines much of the SQL surface I expect from PostgreSQL with the portability of SQLite. A complete database can live in one file, but it still supports analytical queries, full-text search, geospatial operations, Parquet, and direct access to S3. For many small and medium products, it can handle both ordinary application data and serious analytics without requiring a separate analytical cluster.

[QuackDB](https://github.com/elixir-vibe/quackdb) makes DuckDB usable as part of an Elixir application. It provides an OTP-supervised DuckDB process, a `DBConnection` client, an Ecto adapter, streaming and native append APIs, and integrations with [Explorer](https://github.com/elixir-explorer/explorer) and geospatial data.

DuckDB is becoming the common storage layer across the platform: application records, agent sessions, code indexes, analytics, traces, and other operational data can use the same portable foundation.

I started [QuackDB](https://github.com/elixir-vibe/quackdb) while DuckDB’s Quack client-server protocol was still experimental, but the situation has changed quickly. In [DuckDB 2.0 alpha](https://duckdb.org/2026/09/02/try-duckdb-20-alpha.html), the Quack extension is moving from 0.x to 1.0, with higher query throughput and better compatibility. Amazon has also [signed an agreement to acquire DuckLabs](https://aws.amazon.com/blogs/big-data/aws-and-ducklabs-building-the-future-of-analytics-together/). DuckDB’s creators will continue leading its technical direction, while the project remains under the independent DuckDB Foundation and the MIT license. I consider DuckDB a strong long-term bet.

Not every product needs an LLM, but most now call one, and every product eventually depends on external APIs.

[LLMProxy](https://github.com/elixir-vibe/llm_proxy) provides one execution path for model calls. It handles provider routing, fallback models, credential pools, quotas, usage accounting, tracing, and cost. It can run inside an Elixir application or expose OpenAI- and Anthropic-compatible HTTP APIs for other clients.

The application and its agents do not each need their own provider integrations and accounting. Model selection can change without rewriting every caller, and the founder can see where tokens are being spent across products and agents.

I found the same pattern repeated with non-LLM services. A startup gradually accumulates APIs for email, advertising, payments, image generation, vectorization, search, and hosting. Each integration comes with its own authentication, retries, limits, credentials, errors, and accounting.

[Egress](https://github.com/elixir-vibe/egress) generalizes the approach I started with [LLMProxy](https://github.com/elixir-vibe/llm_proxy). An external service is described once as a set of typed operations. The same definition can produce an Elixir client or a standalone proxy route, while calls pass through one runtime path for authentication, retries, quotas, routing, tracing, and accounting.

The unit an agent works with is an operation such as `create_campaign`, `send_email`, or `vectorize_image`, with a contract, rather than an HTTP URL and a provider’s authentication scheme.

There will also be more conventional application building blocks: authentication and authorization, accounts, files, notifications, realtime features, billing, and the other things for which founders currently reach for [Supabase](https://supabase.com) or libraries such as [Better Auth](https://www.better-auth.com). I do not intend to rebuild everything. The goal is coherent Elixir APIs and defaults, using existing projects where they fit and filling gaps where they do not.

## Deployment without another platform

Once the application is built, it still has to run somewhere.

For small products, deployment often introduces another large stack: container registries, orchestration, managed databases, queues, proxies, secret stores, and several dashboards. These tools can be justified at a certain scale, but I do not want every experiment to begin with them.

Elixir already has a good deployment unit: an OTP release containing the application, its dependencies, and the runtime it needs.

[ReleaseKit](https://github.com/elixir-vibe/release_kit) turns a Mix release into a repeatable, deployment-neutral artifact. It produces an ordinary tarball and a small manifest describing how to run it, which environment it expects, and how to check its health. It deliberately knows nothing about servers, users, systemd, or reverse proxies.

[HostKit](https://github.com/elixir-vibe/host_kit) handles the other half. It describes a Linux host in Elixir: packages, users, services, secrets, firewall rules, and [Caddy](https://caddyserver.com) reverse-proxy routes. It reads the current state, produces a plan, and applies the reviewed plan locally or over SSH. A host is ordinary Elixir:

```elixir
use HostKit.DSL, providers: [HostKit.Providers.Caddy]

project :prod do
  host :app, at: "app.example.com" do
    ssh do
      user "root"
      identity_file Path.expand("~/.ssh/id_ed25519")
    end
  end

  service :api do
    daemon :api do
      exec argv("/opt/api/bin/server", opts: [port: 4000])

      isolate do
        memory_max "512M"
        network :loopback
      end

      listen :http, port: 4000
    end

    caddy_site "api.example.com" do
      reverse_proxy :http
    end
  end
end
```

The result is based on ordinary Linux components. Services run under systemd with restart policies, resource limits, filesystem restrictions, and network isolation. [HostKit](https://github.com/elixir-vibe/host_kit) can bootstrap an empty machine, so the target does not need Elixir, Mix, Docker, or the application runtime installed in advance.

[HostKit](https://github.com/elixir-vibe/host_kit) is a library first; its Mix tasks are wrappers around normal Elixir APIs. The desired host state, current state, plan, apply process, health checks, drift, host facts, and rollback operations are all programmatically accessible.

Infrastructure becomes another part of the system an agent can query: listening ports, failed services, declared resources, a plan explained before it is applied, and a rollback afterwards.

[HostKit](https://github.com/elixir-vibe/host_kit) is still a beta, but it runs my own infrastructure. It will not replace every cloud platform. It makes deploying a small or medium product cheap and understandable, with infrastructure as observable as every other part of the platform.

Once the product is running, the more interesting question begins: what are users doing, where did they come from, what is breaking, and what should change next?

## From analytics to the next decision

The answers are usually divided among unrelated systems. Advertising platforms know the campaign and its cost. Web analytics knows the landing page and conversion. Session-recording software knows what happened in the browser. Application monitoring has the errors and traces. The BEAM knows the live process state. An LLM provider knows how many tokens were spent. None of them has the complete context.

I started experimenting with this in [my fork](https://github.com/dannote/analytics) of [Plausible Analytics](https://plausible.io). I am porting its analytics storage to DuckDB through [QuackDB](https://github.com/elixir-vibe/quackdb). The goal is to keep traffic, funnels, attribution, conversions, and other product analytics in the same portable data layer as the rest of the platform, without requiring separate managed PostgreSQL and [ClickHouse](https://clickhouse.com) instances for every product.

Aggregate analytics still cannot explain what happened to one particular user. For that, I built [PhoenixReplay](https://github.com/elixir-vibe/phoenix_replay).

In a Phoenix LiveView application, much of the interface state lives on the backend. The browser displays updates produced from that state. This creates an unusual opportunity: instead of recording only clicks and DOM changes in the browser, [PhoenixReplay](https://github.com/elixir-vibe/phoenix_replay) can record the backend state and use it to recreate what the user saw. We can replay both sides of the session: the frontend experience and the backend state that produced it.

The next step is to connect these sources rather than open them in separate dashboards.

Suppose a customer arrives through a paid campaign, begins registration, gets stuck, and leaves. I want to see where they came from and how much that acquisition cost, replay what they experienced in the browser together with the corresponding backend state, inspect related errors and traces, and follow the relevant code path. If an LLM or another paid API participated in the request, its latency and cost should be visible too.

<.evidence_chain />

[Incant](https://github.com/elixir-vibe/incant) is the common admin interface I am building for this. It is intended to show ordinary application records, analytical datasets, campaign performance, replay sessions, telemetry, LLM traces, agent state, infrastructure, and other operational data through the same set of Elixir APIs.

This is useful not only for the founder. An agent can query the same data and correlate it across subsystems. A background agent could notice that conversion from a campaign dropped, identify the affected landing page, inspect recent sessions, find where users started abandoning the funnel, and suggest a next step with the evidence that led to it.

These are suggestions with evidence attached, not autonomous decisions. An agent may propose changing a bid, pausing a campaign, investigating a slow request, or modifying a signup step. The founder can inspect the reasoning and approve the action.

## How this differs from Figma, Lovable, and Replit

Figma is a different case. I am not building a better Figma. I am making `.fig` a format that any tool can read, render, and write. Design tools are priced as if the editor were the only place a design can live, and the subtitle of this post is what happens to that price when it is not.

Lovable and Replit concentrate mainly on turning a prompt into a working and deployed application. I am trying to cover a larger part of the founder’s work: exploring several design directions, building the application, checking how it evolves, operating it, acquiring users, understanding their behavior, and feeding that evidence into the next decision.

The technical foundation is different too. Skills can improve an agent working on a JavaScript or Python project, but they cannot change the execution model or remove the conflicting conventions the agent has learned from those ecosystems. My approach uses Elixir and OTP as the common environment, then adds structural code analysis, observable JavaScript execution, shared storage, deployment APIs, and access to live product data.

Lovable and Replit grew out of venture-capital culture, where rapid user growth can take priority over margins and usage can be subsidized while a company searches for scale. I am building from the perspective of a technical founder spending his own money. Infrastructure cost, API usage, acquisition cost, conversion, and the work required to operate the product are part of the system from the beginning.

## What exists today

This post describes the system I am building, not a finished product that can be installed with one command.

Most of the building blocks are public and useful independently. The map under the summary marks which are published and which are still alpha or beta.

The main missing piece is integration. These projects already use one another—[Volt](https://github.com/elixir-volt/volt) uses [QuickBEAM](https://github.com/elixir-volt/quickbeam), [Exograph](https://github.com/elixir-vibe/exograph) uses [QuackDB](https://github.com/elixir-vibe/quackdb) and [ExAST](https://github.com/elixir-vibe/ex_ast), [HostKit](https://github.com/elixir-vibe/host_kit) consumes [ReleaseKit](https://github.com/elixir-vibe/release_kit) artifacts, and my projects run the quality tools on themselves—but they do not yet form one coherent founder-facing product.

Agents let me cover a lot of ground alone, but they cannot provide the variety of real use that a community can. Publishing each building block separately puts it in front of files, operating systems, and workflows I never tested. Bug reports expose my assumptions, and contributions take the projects beyond my own needs. Open source is how I develop the platform as much as how I distribute it.

## What comes next

I have spent most of this year building and extracting the missing parts. The next phase is less about adding more foundations and more about connecting what already exists.

The most immediate product is OpenPencil Cloud: optional workspaces, synchronization, sharing, comments, collaboration, and team component libraries. Local files will remain first-class, and the backend will also be self-hostable.

I also want to turn reference collection, alternative drafts, comparison, and iterative work with agents acting as designers into one coherent [OpenPencil](https://github.com/open-pencil/open-pencil) workflow. A related service may provide common access to language and vision models, image generation, vectorization, SVG generation, and other design APIs—something like [OpenRouter](https://openrouter.ai) focused on design—while continuing to support users’ own credentials.

The path through [VuePencil](https://github.com/dannote/vue-pencil), the coding environment, and the rest of the platform then needs to become a product rather than a diagram. That includes filling conventional gaps such as authentication and file storage, and connecting [Incant](https://github.com/elixir-vibe/incant) to the operational sources that already exist.

Some packages will merge, some abstractions will change after real use, and some experiments will fail. Publishing the pieces independently is how I find out which.

## How to help

This is still mostly a one-person effort, and there are more useful directions than I can pursue at once. The best way to help is to use the projects in situations I have not considered, report what breaks, and tell me which parts are useful outside my own workflow. Contributions are welcome too.

Until now, I have paid for the development and infrastructure myself. I am beginning to look for sponsors, grants, infrastructure partners, and companies interested in supporting particular parts of the work. I am also preparing OpenPencil Cloud as the first commercial service around the open-source projects.

If you use any of these tools, want to contribute, or represent an organization interested in supporting the work, please contact me at [hello@dannote.net](mailto:hello@dannote.net).
