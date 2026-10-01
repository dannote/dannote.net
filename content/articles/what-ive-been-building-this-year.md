---
title: "What I’ve been building this year"
description: An end-to-end open-source platform for startup factories, assembled one missing building block at a time.
subtitle: "Or: how the hell are all these things related?"
date: 2026-10-02
updated: 2026-10-02
language: en
draft: false
tags:
  - open source
  - coding agents
  - Elixir
  - design tools
---

Since the beginning of this year, I have released dozens of open-source projects.

There is a [Figma-compatible design editor](https://openpencil.dev), a [JavaScript runtime](https://github.com/elixir-volt/quickbeam) for the [BEAM](https://en.wikipedia.org/wiki/BEAM_%28Erlang_virtual_machine%29), a [frontend build tool](https://github.com/elixir-volt/volt), an [npm client](https://github.com/elixir-volt/npm_ex), several [static analyzers](https://github.com/elixir-vibe/reach), [coding-agent tools](https://github.com/elixir-vibe/vibe), a [DuckDB adapter](https://github.com/elixir-vibe/quackdb), [session replay](https://github.com/elixir-vibe/phoenix_replay), [deployment tooling](https://github.com/elixir-vibe/host_kit), and [many smaller libraries](/projects/) in between.

Judging by my feed, it probably looks like I wake up every few days with an unrelated idea, build it, publish it, and move on to the next one.

That is partly my fault. I have explained each project when I released it, promised to explain how they fit together, and never did.

> All the Elixir libraries I’ve been publishing recently and OpenPencil are part of the same vision. The idea is much bigger than just building another design harness.
>
> — Danila Poyarkov (@dan_note), [23 April 2026](https://x.com/dan_note/status/2047408509445087554)

## TL;DR

I am building an end-to-end open-source platform for startup factories. By a startup factory I mean a venture studio: a small team, often one technical founder working with agents, that launches many products, keeps the ones that work, and kills the rest. The platform follows each product through its whole lifecycle, from references and design drafts through prototypes, code, deployment, and acquisition, to the evidence that decides what to build next.

The process starts in [OpenPencil](https://github.com/open-pencil/open-pencil), a design editor where the founder works with an agent the way they would stand behind a product designer: describing what is in their head, watching drafts appear, and steering until the design on the canvas matches the idea. Selected designs become working [Vue](https://vuejs.org) components. The product then moves into an [Elixir](https://elixir-lang.org) environment that connects coding, deployment, and operation, so a coding agent can see the whole product. If a customer gets stuck, the system can trace where they came from, replay what they saw, re-rendered from the backend state, inspect the code path, and propose a next step with evidence.

My ambition is an open-source platform that can eventually compete with [Figma](https://www.figma.com), [Lovable](https://lovable.dev), and [Replit](https://replit.com) on a technical founder’s terms: a commodity design format, and the work after deployment.

<.building_this_year_project_map />

The rest of this post walks through the map roughly one stage at a time.

## Who I am

I am a programmer, but I have never stayed in one narrow part of the stack. I have done systems programming, contributed to open source in the [Xfce](https://gitlab.xfce.org/xfce/garcon/-/commit/aec77533132eb324180ef771e15226a752573eae) and [nginx](https://github.com/dannote/socks-nginx-module) ecosystems, done white-hat security research through [Google Bug Hunters](https://bughunters.google.com/profile/62602ae8-cf92-4fb0-810c-c9e284f3427e) and [Bugcrowd](https://bugcrowd.com/h/dannote), built web applications, and occasionally worked as a designer. I tend to move to whichever layer contains the problem.

I have also spent a long time working in venture studios, and I have founded and run small companies with my own money.

Running products on my own money made the economics impossible to separate from the product. A percentage point of conversion decides whether a campaign is profitable, and the cost of operating a product decides when to stop. That lens is why the platform described here does not end at deployment.

The first part of that process I tried to improve was design.

## It started with Figma

I created [`figma-use`](https://github.com/dannote/figma-use) to automate repetitive work in Figma. I wanted to inspect layers, make bulk changes, generate component structures, and export assets without clicking through the interface every time.

Figma’s own [MCP](https://modelcontextprotocol.io) server at the time could only read: it exposed the canvas as something close to a node-tree dump, and the agent could not change anything.

Coding agents became useful when the harnesses around them, the tools that wrap a model in a loop, gave them an iterative process: inspect a repository, make a change, run the application, read the error, compare the result with what was expected, try again.

I wanted to give design agents the same kind of loop.

Good design is iterative too. A designer normally begins by collecting references, then draws several drafts, compares them, and chooses a direction. After that comes a longer loop: copy, tweak, compare, choose, and repeat. The first result is rarely the final one.

Most AI design tools ignore this process. They try to generate a finished screen in one shot. Even when the screenshot looks impressive, the structure underneath is often useless: unnamed nested frames, no components, no tokens, and no coherent system that another designer can continue working with.

With [`figma-use`](https://github.com/dannote/figma-use), an agent could work on the actual structure. It could create and modify nodes, use components and variants, describe a screen in JSX and render it as Figma layers, inspect the resulting tree, and continue from there. A `.figma.tsx` file defines components; the first render creates the master, the rest create instances:

```tsx
import { defineComponent, Frame, Text } from 'figma-use/render'

const Card = defineComponent(
  'Card',
  <Frame style={{ p: 24, bg: '#FFF', rounded: 16, flex: 'col', gap: 12 }}>
    <Text style={{ size: 22, weight: 'bold' }}>Card / Header</Text>
    <Text style={{ size: 14, color: '#555' }}>Updated 2 min ago</Text>
    <Frame style={{ p: 10, bg: '#2563EB', rounded: 8 }}>
      <Text style={{ color: '#FFF' }}>Reply</Text>
    </Frame>
  </Frame>
)

export default () => <Card />
```

I added visual diffing so it could see what changed, and design linting so it could catch structural and accessibility problems. I also wanted design files in automated pipelines: linted in CI, compared between revisions, and exported without anybody opening Figma.

<.building_this_year_design_diff />

Then Figma [released an update](https://github.com/dannote/figma-use/issues/6#issuecomment-3925136616) that blocked the debugging interface [`figma-use`](https://github.com/dannote/figma-use) relied on.

I found workarounds and kept the tool working, but the larger lesson was obvious. I could not build this kind of infrastructure on access that a vendor could remove at any moment. If agents were going to treat design as a real programmable medium, the editor itself had to be open.

That is how [OpenPencil](https://github.com/open-pencil/open-pencil) began.

> Figma shipped a silent patch specifically to kill figma-use — my open-source tool that did what they wouldn't: an MCP server that creates and modifies designs, JSX export, design linting. Then they scrambled to catch up with their own MCP server.
>
> So I spent the weekend recreating Figma from scratch.
>
> OpenPencil: reads and writes .fig files, AI chat with full design tools, P2P collaboration with zero servers, ~7 MB app. No account, no subscription.
>
> Three days, one developer, MIT license.
>
> <https://openpencil.dev>
>
> — Danila Poyarkov (@dan_note), [1 March 2026](https://x.com/dan_note/status/2028201388074013048)

## OpenPencil became a toolkit

[OpenPencil](https://github.com/open-pencil/open-pencil) initially gave me an independent environment for the work I had started with [`figma-use`](https://github.com/dannote/figma-use). It could open and write `.fig` files, render them without Figma, and let agents modify the actual document structure.

While refactoring the project, I realized that the editor itself should not be the only useful result. I split the monolith into packages: the file format parsers, the scene graph, the editor core, the CLI, the MCP server, and a headless Vue SDK. The [OpenPencil](https://github.com/open-pencil/open-pencil) application is now one consumer of them.

The Vue SDK lets developers construct a different editor shell around the same engine. They can embed an editing surface into their product, expose a restricted editor for a particular workflow, or add design tools to an IDE without forking the [OpenPencil](https://github.com/open-pencil/open-pencil) interface.

The engine does not require an editor UI at all. A script or CI job can query a `.fig` file, lint it, extract tokens, convert it, render it, compare it with another revision, or modify it through the same operations used by the application and its agents.

The application itself has moved quickly this year. It opens `.fig` and its own `.pen` files, imports and exports the formats designers and developers already use, from HTML and Tailwind to PPTX and Storybook, and collaborates peer to peer with no server. Agents reach it through MCP, WebMCP, ACP, and a companion runtime that runs [Pi](https://github.com/badlogic/pi-mono) inside the app.

My goal is to make `.fig` a commodity. If independent software can parse, query, render, modify, and convert the format, it stops being something that can only be fully used inside Figma. It becomes input for other editors, IDEs, and automated pipelines.

This solves access to the design structure, but not the boundary between a design and the application eventually built from it.

## From designs to real components

The next direction I started exploring is [VuePencil](https://github.com/dannote/vue-pencil): something like Figma, but for Vue components.

> Here’s a teaser for another project I’ve been working on for a while.
>
> It’s the next generation of OpenPencil — a visual editor where you draw directly in code. Compose real Vue components, nest slots, bind them to composables, use headless UI primitives like Reka, and export code that’s meant to run.
>
> Most attempts I’ve seen fall into two traps: inventing a JSON model for canvas items, then fighting to map it back to components — or trying to WYSIWYG-edit HTML, where the editor and app end up fighting over the same DOM, runtime, and iframe boundaries, slowly turning into a worse Chrome DevTools.
>
> VuePencil starts from the VNode tree. The visual editor is just another way to edit that tree.
>
> ![A frame from the VuePencil demo video: a canvas with real Vue components selected, next to the generated code.](images/x/dan_note-2058490589356707903.jpg)
>
> — Danila Poyarkov (@dan_note), [24 May 2026](https://x.com/dan_note/status/2058490589356707903)

Many visual HTML builders have an abstraction problem. The editor is already an HTML application, and then it tries to build another HTML application inside itself. The layers gradually leak into each other. The tool either supports only a restricted subset of HTML and becomes brittle, or exposes more and more browser internals until it turns into a complicated version of developer tools.

Vue already has a suitable abstraction for this: the VNode tree, its in-memory description of what it renders. In [VuePencil](https://github.com/dannote/vue-pencil), that tree is the source of truth. Editor operations change the model, Vue renders it, and the editor reads the resulting geometry to position selections and handles. It does not directly rewrite the rendered DOM.

This also means that the things placed on the canvas can be real components. The current prototype supports [Reka UI](https://reka-ui.com) primitives, component parts, named slots, props, bindings, and [VueUse](https://vueuse.org) composables. A switch on the canvas is the real component, and it works in preview mode:

```vue
<SwitchRoot v-model="enabled">
  <SwitchThumb />
</SwitchRoot>
```

The result can be serialized as a normal Vue [SFC](https://vuejs.org/guide/scaling-up/sfc.html). Frames and canvas positions remain editor metadata. Slots become Vue slots, capabilities become composable calls, and bindings become ordinary Vue expressions.

This makes prototypes much more useful than links between static screens. A founder can continue the design process with working state and interactions, then take the resulting components into the coding environment. [VuePencil](https://github.com/dannote/vue-pencil) is still an early experiment. It is the direction I want [OpenPencil](https://github.com/open-pencil/open-pencil) to grow in: a canvas of real components, past Figma compatibility.

## Why Elixir?

Once the prototype becomes a real application, design is only one part of the problem. You need a backend, storage, background jobs, external APIs, deployment, analytics, and a way for agents to work with all of them. The question was which language all of that should speak.

For mathematics there is [Lean](https://lean-lang.org). Every definition, theorem, and proof is written in one language and checked by one small, trusted kernel. A model trained on Lean does not spend capacity learning five notations for the same idea, and every step it takes gets a verdict. My bet is that this is why such models reason so densely.

<.building_this_year_lean_sample />

I want the same for the web stack: one language in which bundling, the JavaScript runtime, storage, the backend, deployment, and operations share the same kind of API, the same runtime, and the same checks, while JavaScript, Rust, and SQL keep doing their jobs underneath. Elixir is the closest thing I found, and the rest of this post is what it took to make that true. I first wrote about this intuition in [“A language for humans and models”](/writing/a-language-for-humans-and-models/).

All of it in one session, the same one an agent works in:

```elixir
# Build the frontend.
{:ok, build} = Volt.build()

# Run JavaScript inside the application, as a supervised process.
{:ok, html} = QuickBEAM.call(:renderer, "render", [%{page: "home"}])

# Search the code by structure.
ExAST.search("lib/", "Repo.transaction(_)", inside: "def _ do ... end")

# Build the dependence graph of a file.
graph = Reach.file_to_graph("lib/payments.ex")

# Call a model through one path, with quotas and accounting.
{:ok, reply} = LLMProxy.chat("Summarize this incident", model: "fast")

# Query the analytics store.
MyApp.AnalyticsRepo.all(MyApp.Analytics.category_latency())

# Fetch what one user saw.
recording = PhoenixReplay.Recordings.fetch!(id)

# Plan and apply the host.
{:ok, plan} = HostKit.plan(project, target: :prod)
HostKit.apply(plan, confirm: true)

# Ask the runtime itself.
Supervisor.which_children(MyApp.Supervisor)
```

I was skeptical when José Valim, the creator of Elixir, published [“Why Elixir is the best language for AI”](https://dashbit.co/blog/why-elixir-best-language-for-ai). A benchmark result like the [AutoCodeBench](https://autocodebench.github.io/) score he cites says little on its own. One of his reasons stuck with me, though: the ecosystem has stayed stable, so a model has not learned five generations of conflicting APIs. After a few months of building Elixir with agents, I agreed.

Elixir is dynamic too, so this is not typed versus untyped. But data flow is explicit, pattern matching puts contracts in the code, conventions are consistent, and the compiler and the growing type system catch more with every release.

In JavaScript and Python projects I see the opposite. Strict types sit on top of those languages as optional layers, while their ecosystems contain many competing generations of tools and conventions. Agents mix ESM with CommonJS, use an old framework pattern beside a new one, hand-roll something the project already has, or create another implementation because they did not find the first one. Skills and prompts can reduce this, but they do not change the language underneath.

Then there is [OTP](https://www.erlang.org/doc/system/design_principles.html), the framework of processes and supervisors that Elixir inherits from Erlang. User sessions, background jobs, external API calls, and agent runs can all be represented as isolated processes with explicit ownership and supervision. One process can fail without taking the rest of the application with it. The running system is also directly inspectable. The questions an engineer asks in a shell, an agent can ask too, one call each.

<.building_this_year_runtime_map />

José made the same argument from the tooling side in [“The future of coding agents is vertical integration”](https://tidewave.ai/blog/the-future-of-coding-agents-is-vertical-integration): an agent works much better when it can connect source code to the browser, logs, database, and running application instead of asking the developer to translate between them.

## Checking what agents write

Lean is only half notation. The other half is the kernel, which tells the model whether each step holds. Elixir's compiler, [Dialyzer](https://www.erlang.org/doc/apps/dialyzer/dialyzer.html), and tests are a start, but the scale at which agents produce code created a problem none of them catch: keeping that code coherent over time.

Agents tend to focus on the immediate task. They often fail to notice that a similar implementation already exists elsewhere, so they create another one. The copies then evolve separately: a bug is fixed in one but not the other, their behavior gradually diverges, and later agents add another variation because they cannot tell which one is canonical. This is one of the classic ways a vibe-coded codebase turns into a mess.

I started turning the checks I was performing during reviews into tools.

[ExAST](https://github.com/elixir-vibe/ex_ast) is structural search and replacement for Elixir. [Grit](https://github.com/getgrit/gritql) rewrites code with structural patterns and [CodeQL](https://codeql.github.com) queries it as a database, both across many languages through a neutral layer. ExAST is Elixir-native: a pattern is ordinary Elixir code, matched against the AST the compiler itself produces. Instead of grepping source text or inventing a regular expression, an agent searches for an Elixir syntax pattern and rewrites the matching nodes.

The questions a reviewer asks about generated code become queries over the tree:

```elixir
import ExAST.Query

# Transactions that still have debug output inside them.
from("def _ do ... end")
|> where(contains("Repo.transaction(_)"))
|> where(contains("IO.inspect(...)"))

# Handlers for the two events the interface actually sends.
from("def handle_event(event, _, _) do ... end")
|> where(^event == :click or ^event == :keydown)

# Comparisons that are always true.
from("left == right") |> where(^left == ^right)
```

Rewrites are patterns on both sides, and the agent sees a plan of every replacement and conflict before anything is applied. The same engine diffs code structurally, so a function that moved is reported as a move. ExAST sees structure only, so a plan is a proposal; whether a rewrite is safe still takes judgment.

[ExDNA](https://github.com/elixir-vibe/ex_dna) detects duplicated code structurally and says how to fix it. It finds exact copies and copies with renamed variables by default, and near-duplicates with changed literals when asked, then proposes the extraction: a function, a macro, or a behaviour. It runs as a compiler step, a Credo check, or a language server, so the same finding reaches CI and the editor. I use it with a zero-duplication budget in most of my projects.

[ExSlop](https://github.com/elixir-vibe/ex_slop) is a set of Credo checks for the other patterns generated code repeats: identity passthroughs, blanket rescues, queries inside `Enum.map`, and docs that narrate the code beneath them.

These tools mostly see local structure. A function can look reasonable in isolation while creating a bad dependency, bypassing an architectural boundary, or allowing untrusted input to reach a database, filesystem, or shell command.

[Reach](https://github.com/elixir-vibe/reach) builds a program dependence graph for Elixir, Erlang, Gleam, JavaScript, and TypeScript: calls, control flow, data flow, effects, and OTP process relationships. It answers the questions that span files: what depends on this function, what a change might affect, and whether data can flow from a source to a dangerous effect. The last one is a command, here from request parameters to the database:

```sh
mix reach.trace --from conn.params --to Repo
```

The other questions have the same shape. Here they are asked of QuackDB:

```sh
$ mix reach.map --hotspots --top 3
  score combines branch count with caller impact
  QuackDB.Source.literal!/1  score=96  branches=4  callers=24
  QuackDB.SQL.literal/1      score=77  branches=7  callers=11
  QuackDB.SQL.literal!/1     score=31  branches=1  callers=31

$ mix reach.otp --concurrency
  Tasks        async      lib/quack_db/server.ex:423   1 async without matching await
  Monitors     trap_exit  lib/quack_db/server.ex:196
  Supervisors             lib/quack_db/application.ex:12
```

[Reach](https://github.com/elixir-vibe/reach) also turns architecture into something agents can check. A project declares its layers and forbidden dependencies, and changes that cross them are rejected. Findings are advisory by default, and every suggested fix is labeled equivalent, conditional, or review-only, so an agent can tell a proven rewrite from a lead.

This site has [such a policy](https://github.com/dannote/dannote.net/blob/main/.reach.exs). Three layers, and the lower ones may not reach up:

```elixir
[
  layers: [
    site: "Blog.Site",
    plugins: ["Blog.SocialImages", "Blog.Markdown.*"],
    previews: "Blog.LinkPreview*"
  ],
  deps: [forbidden: [{:site, :plugins}, {:site, :previews}, {:plugins, :previews}]],
  calls: [forbidden: [{"Blog.LinkPreview", "Req.get/2"}]]
]
```

The last line is a trap I set for the example, and the check walks into it:

```sh
$ mix reach.check --arch
  1 violation(s)
  lib/blog/link_preview.ex:88 Blog.LinkPreview calls Req.get/2 (configured forbidden call)
** (Mix) Architecture policy failed
```

Smell findings carry the label in their JSON, the form an agent reads. Reach found these two in this site while I was writing the paragraph:

```json
{"kind": "suboptimal", "location": "lib/blog/highlight.ex:33",
 "message": "Enum.map_join/3 defaults to empty separator; remove the \"\" argument",
 "remediation_safety": "equivalent"}
{"kind": "suboptimal", "location": "lib/blog/link_preview.ex:179",
 "message": "String.split/2 |> hd/1 splits the entire string; use String.split/3 with parts: 2",
 "remediation_safety": "review_only"}
```

The first is a proven rewrite. The second needs a look, because `parts: 2` changes what the function returns when the string has more than one separator.

But adding more checks creates its own risk. A false positive is annoying for a human, but an agent may obey it and make the code worse just to silence the warning. A rule that looks convincing in a few hand-written examples may fail on perfectly reasonable code in a real project.

That is why I built [Exograph](https://github.com/elixir-vibe/exograph): local [CodeQL](https://codeql.github.com)-style code search for Elixir, backed by DuckDB through [QuackDB](https://github.com/elixir-vibe/quackdb) and [ExAST](https://github.com/elixir-vibe/ex_ast). It indexes the entire public [Hex](https://hex.pm) package ecosystem and queries it by structure, similarity, and call graph. Running a proposed rule across that corpus is how I find false positives and decide whether it is reliable enough to keep.

As I was finishing this post, José Valim argued in [“Evolving programming languages in the AI era”](https://dashbit.co/blog/evolving-ai-era) that agents need stronger guarantees and a program database with a query language more than an editor protocol built for humans. [Reach](https://github.com/elixir-vibe/reach) and [Exograph](https://github.com/elixir-vibe/exograph) are my attempt at that database for Elixir: facts about calls, data flow, effects, and architecture that an agent can query.

The same tools are used to check themselves. My projects combine the compiler, tests, Dialyzer, [ExDNA](https://github.com/elixir-vibe/ex_dna), [ExSlop](https://github.com/elixir-vibe/ex_slop), [Reach](https://github.com/elixir-vibe/reach), and architecture rules. [VibeKit](https://github.com/elixir-vibe/vibe_kit) installs that setup into a new or existing project with one command.

None of this makes blind vibe coding safe. It reduces some kinds of ambiguity, catches structural drift earlier, and gives agents more precise feedback when their work does not fit the rest of the system.

## Frontend tooling in Elixir

Choosing Elixir did not remove the need for JavaScript. The npm ecosystem contains too much useful work, and Vue is a good abstraction for building interfaces. Rewriting all of it in Elixir would make no sense.

The problem was the separate operational world around it: Node processes, package managers, framework compilers, bundlers, and CSS tools, each with its own configuration and lifecycle. Calling JavaScript from Elixir is easy; start a Node process and exchange JSON. I wanted JavaScript execution to be observable and controllable as part of the same system.

That led to [QuickBEAM](https://github.com/elixir-volt/quickbeam).

In [QuickBEAM](https://github.com/elixir-volt/quickbeam), JavaScript runtimes and contexts behave like part of an OTP application. They have process ownership, participate in supervision trees, exchange messages with BEAM processes, and can be monitored, stopped, restarted, and inspected. JavaScript values map directly to BEAM terms.

Execution can also be constrained by memory and an instruction budget per call, in the spirit of BEAM reductions, so runaway JavaScript does not have unlimited control of the host application. Large numbers of lightweight contexts can share a small pool of runtime threads. Browser APIs such as workers, timers, storage, and networking are backed by OTP primitives, and runtimes can call each other across Erlang nodes.

In August it went a step further, with an interpreter that runs QuickJS bytecode as BEAM code. Each call gets a fresh heap, the scheduler can preempt it like any other process, and a failure is contained to one evaluation. I wrote about it in [“JavaScript as BEAM code”](/writing/javascript-as-beam-code/).

JavaScript remains available where the ecosystem requires it, but it no longer disappears into an opaque Node sidecar.

Package management came next. [`npm_ex`](https://github.com/elixir-volt/npm_ex) resolves, fetches, caches, and links npm packages from Mix, with no Node on the machine. It started as a small library for inspecting `package.json` and dependency trees, then grew into most of a package manager: a PubGrub resolver, a reproducible lockfile, and a global cache. It is also stricter than npm by default. Lifecycle scripts never run on their own, transitive git and URL dependencies are blocked, and an audit checks packages against the OSV list of malicious releases.

I also created Elixir bindings for the Rust tools that already do much of the real work in modern frontend toolchains: [OXC](https://oxc.rs) for JavaScript and TypeScript, [Vize](https://github.com/ubugeeei/vize) for Vue, and [Tailwind](https://tailwindcss.com)’s Oxide scanner, which finds class names in source files. These projects did not need to be rewritten; they needed APIs the BEAM could call directly.

[Volt](https://github.com/elixir-volt/volt) assembles these pieces into one frontend toolchain that replaces esbuild, the Tailwind CLI, and Node.js: a development server with hot module replacement, linting, and production builds for TypeScript, Vue, React, Svelte, and Solid. JavaScript tests run inside `mix test`, and since September every error in the chain, from OXC through [QuickBEAM](https://github.com/elixir-volt/quickbeam) and Volt to [PhoenixVapor](https://github.com/elixir-volt/phoenix_vapor), has the same diagnostic shape with file, line, and column. The toolchain starts with the application and can be configured, observed, and extended from Elixir.

<.building_this_year_volt_tree />

This removes one boundary, but frontend and backend code can still describe two halves of the same behavior and quietly disagree.

[PhoenixVapor](https://github.com/elixir-volt/phoenix_vapor) explores a more direct bridge. It compiles Vue template syntax into native [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view) rendering structures, so it uses the same diff protocol with no wrapper elements. It has four modes: Vue syntax with no client JavaScript, server-side reactivity through [QuickBEAM](https://github.com/elixir-volt/quickbeam), a full Vue runtime on the server that renders third-party component libraries without shipping them to the browser, and a hybrid where the server owns application data while the browser owns local interface state.

<.building_this_year_vapor_wire />

This connects back to [VuePencil](https://github.com/dannote/vue-pencil). A component created there can remain a real Vue component. It can become an ordinary client-side Vue application built by [Volt](https://github.com/elixir-volt/volt), a Vue island embedded in a server-rendered [Phoenix](https://www.phoenixframework.org) page, or a template compiled into LiveView.

## The coding environment

I am a big fan of [Pi](https://github.com/badlogic/pi-mono), Mario Zechner’s coding agent. Its core is deliberately small, and extensions, skills, and prompt files let me adapt it to my workflow, so I first built [pi-elixir](https://github.com/elixir-vibe/pi-elixir) as a [Pi](https://github.com/badlogic/pi-mono) extension.

[pi-elixir](https://github.com/elixir-vibe/pi-elixir) connects [Pi](https://github.com/badlogic/pi-mono) to the BEAM through three tools: evaluate Elixir, and search and rewrite the AST with [ExAST](https://github.com/elixir-vibe/ex_ast). Evaluation can target the project, the running application, or a remote node, and values persist between calls like an IEx or Livebook session. The target project needs no change to its mix file.

But the more I extended the harness, the less natural its underlying execution model felt for the direction I wanted to take.

A coding harness is a concurrent, long-running system: model streams, terminal input, tool execution, background work, cancellation, retries, persistence, and eventually other agents. [Pi](https://github.com/badlogic/pi-mono) implements all of this carefully in JavaScript, but the work still travels through layers of promises, callbacks, and terminal redraws inside one process, with ownership and failure boundaries maintained by convention. OTP has a more direct model. A session is a process, a model request and each tool execution are supervised children, and terminal, browser, and remote clients observe the session without owning it. Processes can be monitored, cancelled, restarted, or allowed to fail independently, and the scheduler preempts them.

I built [Vibe](https://github.com/elixir-vibe/vibe) to explore this architecture without the constraints of an existing harness.

In [Vibe](https://github.com/elixir-vibe/vibe), sessions, agents, subagents, commands, and interfaces are OTP processes. Agents can start other agents and communicate through messages. They can run on one node or communicate across machines through Erlang distribution and SSH. Closing a terminal does not have to stop the work, and a failing subagent does not have to destroy its parent session. A background server owns the sessions, like tmux, so several terminals or a LiveView console can attach to the same one, and memory and past transcripts are searchable. Vibe can also run its own checks, patch its own code, and hot-reload the result, which makes it a first step toward agents that modify and improve themselves.

<.building_this_year_vibe_tree />

OpenAI reached the same conclusion. The reference implementation of [Symphony](https://github.com/openai/symphony), its system for supervising long-running coding-agent work, is written in Elixir.

[Vibe](https://github.com/elixir-vibe/vibe) is useful, but it is also an experiment. I do not want to force users to replace a mature harness with my half-finished one just to test each hypothesis. When an idea works in [Vibe](https://github.com/elixir-vibe/vibe), I can bring it back into [pi-elixir](https://github.com/elixir-vibe/pi-elixir) and test it inside [Pi](https://github.com/badlogic/pi-mono). The newer [pi-elixir](https://github.com/elixir-vibe/pi-elixir) combines [Pi](https://github.com/badlogic/pi-mono)’s model support, interface, and extension system with more of the BEAM-native runtime and structural tooling explored in [Vibe](https://github.com/elixir-vibe/vibe).

[Tilde](https://github.com/elixir-vibe/tilde) develops another part of this architecture: separating an agent session from any particular interface.

A [Tilde](https://github.com/elixir-vibe/tilde) session is a stream of semantic events: a message was added, a tool started, output arrived, a choice was requested, or an agent completed its work. The same session can be rendered in a terminal, in a browser with LiveView, over SSH, or as structured data. Sessions persist through [QuackDB](https://github.com/elixir-vibe/quackdb), so one can be resumed after a restart, searched, and served over LiveView and SSH at the same time.

## Common storage and APIs

A platform for building several products should not require a separate collection of managed services for each one. I wanted the default setup to remain cheap, portable, and easy to run locally.

For storage, I settled on [DuckDB](https://duckdb.org).

DuckDB combines much of the SQL surface I expect from PostgreSQL with the portability of SQLite. A complete database can live in one file, but it still supports analytical queries, full-text search, geospatial operations, Parquet, and direct access to S3. For many small and medium products, it can handle both ordinary application data and serious analytics without requiring a separate analytical cluster.

```sql
-- A campaign funnel, straight from a month of Parquet files on S3.
SELECT utm_campaign,
       count(DISTINCT session_id)                                AS sessions,
       count(DISTINCT session_id) FILTER (WHERE name = 'signup') AS signups,
       count(DISTINCT session_id) FILTER (WHERE name = 'paid')   AS paid,
       round(100.0 * paid / sessions, 1)                         AS conversion
FROM read_parquet('s3://analytics/events/2026-09-*.parquet')
GROUP BY ALL
QUALIFY row_number() OVER (ORDER BY conversion DESC) <= 10;
```

[QuackDB](https://github.com/elixir-vibe/quackdb) makes DuckDB usable as part of an Elixir application: an OTP-supervised DuckDB process, a `DBConnection` client, an Ecto adapter, native append and streaming, and a query DSL so most work never touches raw SQL.

```elixir
from e in Source.parquet("s3://analytics/events/2026-09-*.parquet"),
  group_by: e.utm_campaign,
  select: %{
    campaign: e.utm_campaign,
    sessions: count(e.session_id, :distinct),
    signups: filter(count(e.session_id, :distinct), e.name == "signup"),
    paid: filter(count(e.session_id, :distinct), e.name == "paid")
  }
```

DuckDB is becoming the common storage layer across the platform. [Exograph](https://github.com/elixir-vibe/exograph)’s index lives in it, [pi-elixir](https://github.com/elixir-vibe/pi-elixir) mirrors its sessions into it, [Tilde](https://github.com/elixir-vibe/tilde) persists through it, [LLMProxy](https://github.com/elixir-vibe/llm_proxy)’s standalone mode keeps usage in it, and the analytics fork is moving onto it. [Vibe](https://github.com/elixir-vibe/vibe) still keeps its sessions in SQLite.

I started [QuackDB](https://github.com/elixir-vibe/quackdb) while DuckDB’s Quack client-server protocol was still experimental. It has since reached 1.0 in [DuckDB 2.0](https://duckdb.org/2026/09/02/try-duckdb-20-alpha.html), and with DuckLabs [joining AWS](https://aws.amazon.com/blogs/big-data/aws-and-ducklabs-building-the-future-of-analytics-together/) while the project stays MIT-licensed under the independent DuckDB Foundation, I consider it a safe long-term bet.

Storage was one shared service. Model access is the other: not every product needs an LLM, but most now call one, and every product eventually depends on external APIs.

[LLMProxy](https://github.com/elixir-vibe/llm_proxy) is one execution path for every model call, in the spirit of [LiteLLM](https://www.litellm.ai) but Elixir-native: it runs inside the application, or standalone with OpenAI- and Anthropic-compatible endpoints. Callers ask for `fast`, `smart`, or `cheap`. Routing, fallbacks, quotas, and accounting happen behind those names, so a provider can change without touching a caller, and the founder sees where every token went.

I found the same pattern repeated with non-LLM services. A startup gradually accumulates APIs for email, advertising, payments, image generation, vectorization, search, and hosting. Each integration comes with its own authentication, retries, limits, credentials, errors, and accounting.

Egress is the next step, and it is still a design: an external service described once as a set of typed operations, such as creating a campaign or sending an email, that produce both an Elixir client and a proxy route through the same runtime path for authentication, retries, quotas, tracing, and accounting. An agent would call an operation with a contract and never see the URL or the provider’s authentication scheme. The repository stays private until the first operations run.

## Deployment without another platform

Once the application is built, it still has to run somewhere.

For small products, deployment often introduces another large stack: container registries, orchestration, managed databases, queues, proxies, secret stores, and several dashboards. These tools can be justified at a certain scale, but I do not want every experiment to begin with them.

Elixir already has a good deployment unit: an OTP release containing the application, its dependencies, and the runtime it needs.

[ReleaseKit](https://github.com/elixir-vibe/release_kit) turns a Mix release into a repeatable, deployment-neutral artifact. It produces an ordinary tarball and a small manifest describing how to run it, which environment it expects, and how to check its health. It deliberately knows nothing about servers, users, systemd, or reverse proxies.

[HostKit](https://github.com/elixir-vibe/host_kit) handles the other half. It describes a Linux host in Elixir: packages, users, services, secrets, firewall rules, and [Caddy](https://caddyserver.com) reverse-proxy routes. It reads the current state, produces a plan, applies the reviewed plan locally or over SSH, and can bootstrap a bare machine with no Elixir on it. A host is ordinary Elixir:

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

The result is ordinary Linux: services under systemd with restart policies, resource limits, filesystem restrictions, and network isolation. Everything is a library call first, and the Mix tasks are wrappers. So the questions an agent asks the runtime have host-level answers too: which ports listen, which services failed, what a plan would change, and how to roll it back.

[HostKit](https://github.com/elixir-vibe/host_kit) is still a beta, but it runs my own infrastructure. It makes deploying a small or medium product cheap and understandable, with infrastructure as observable as every other part of the platform.

Once the product is running, the more interesting question begins: what are users doing, where did they come from, what is breaking, and what should change next?

## From analytics to the next decision

The answers are usually divided among unrelated systems. Advertising platforms know the campaign and its cost. Web analytics knows the landing page and conversion. Session-recording software knows what happened in the browser. Application monitoring has the errors and traces. The BEAM knows the live process state. An LLM provider knows how many tokens were spent. None of them has the complete context.

I started experimenting with this in [a branch of my fork](https://github.com/dannote/analytics/tree/duckdb-analytics) of [Plausible Analytics](https://plausible.io). ClickHouse is gone from that branch: analytics storage, imports, exports, and the job queue run on DuckDB through [QuackDB](https://github.com/elixir-vibe/quackdb), while Plausible’s own PostgreSQL stays for now. The goal is to keep traffic, funnels, attribution, conversions, and other product analytics in the same portable data layer as the rest of the platform, without a ClickHouse cluster for every product.

Aggregate analytics still cannot explain what happened to one particular user. For that, I built [PhoenixReplay](https://github.com/elixir-vibe/phoenix_replay).

In a Phoenix LiveView application, much of the interface state lives on the backend, and the browser displays updates produced from that state. So instead of recording clicks and DOM changes in the browser, [PhoenixReplay](https://github.com/elixir-vibe/phoenix_replay) records the server’s assigns, sanitizes them, and re-renders them later. The replay shows each screen as the server produced it, next to the state behind it. Because nothing runs in the browser, client-only JavaScript state is outside the recording.

> New package! PhoenixReplay — session recording and replay for Phoenix LiveView.
>
> → Records assigns server-side, replays by re-rendering the actual view — pixel-perfect, not a DOM approximation\
> → Zero client-side JS — no bundle size impact, invisible to users\
> → See actual server state during replay: changesets, Ecto structs, form data\
> → Navigation, page transitions, live_patch — all captured in one session automatically\
> → 30s session = 8 KB
>
> rrweb and friends record DOM mutations client-side: they fight CORS, break on shadow DOM, drift when assets change, and produce approximate replays with visual glitches. None of that applies here — LiveView templates are pure functions, so same assigns = same HTML. The BEAM just keeps the state.
>
> ![A frame from the PhoenixReplay demo video: a recorded LiveView session playing back next to the server state behind it.](images/x/dan_note-2031256903192342649.jpg)
>
> — Danila Poyarkov (@dan_note), [10 March 2026](https://x.com/dan_note/status/2031256903192342649)

The next step is to connect these sources rather than open them in separate dashboards.

Suppose a customer arrives through a paid campaign, begins registration, gets stuck, and leaves. I want to see where they came from and how much that acquisition cost, replay what they saw, screen by screen, from the backend state that produced it, inspect related errors and traces, and follow the relevant code path. If an LLM or another paid API participated in the request, its latency and cost should be visible too.

<.building_this_year_customer_path />

[Incant](https://github.com/elixir-vibe/incant) is the common admin interface for this. Resources, dashboards, datasets, and actions are modules, and a service declares what its admin pages contain, and a standalone Incant host renders them. [LLMProxy](https://github.com/elixir-vibe/llm_proxy)’s provider usage already lives there; replay sessions, telemetry, campaign performance, agent state, and infrastructure are meant to follow through the same Elixir APIs.

An agent can use the same data. A background agent could notice that conversion from a campaign dropped, identify the affected landing page, inspect recent sessions, find where users started abandoning the funnel, and propose a change with the evidence that led to it. Each one arrives as a suggestion with its evidence attached, and the founder approves it or not.

## How this differs from Figma, Lovable, and Replit

Figma is a different case. Once `.fig` is a commodity, a design no longer belongs to the editor it was drawn in.

Going through Figma’s own MCP server is no safer today. Figma’s remote MCP server decides which agents may connect at all: sign-in works only for client names on its list, such as Claude Code or Codex. This week, when Mario Zechner tried to connect [Pi](https://github.com/badlogic/pi-mono), his open-source coding agent, Figma refused it because [Pi](https://github.com/badlogic/pi-mono) identifies itself as `pi`.

> today in MCP land ...
>
> thing are better compared to a year ago, but also worse.
>
> ![A message: I'm trying to connect to Figma's remote MCP server. Figma only accepts certain client names during sign-in, e.g., Claude Code or Codex, but Pi 0.99.1 always sends pi.](images/x/badlogicgames-2105234146499203255.png)
>
> — Mario Zechner (@badlogicgames), [30 September 2026](https://x.com/badlogicgames/status/2105234146499203255)

Lovable and Replit turn a prompt into a deployed application. I am trying to cover the rest of the founder’s work as well: operating the product, acquiring users, understanding what they do, and feeding that evidence into the next decision.

The technical foundation is different too. Skills can improve an agent on a JavaScript or Python project, but they cannot change its execution model or the conflicting conventions it learned there. Mine uses Elixir and OTP as the common environment and adds the checks, the observable JavaScript, the shared storage, and the live product data.

Lovable and Replit grew out of venture-capital culture, where rapid user growth can take priority over margins and usage can be subsidized while a company searches for scale. I am building from the perspective of a technical founder spending his own money. Infrastructure cost, API usage, acquisition cost, conversion, and the work required to operate the product are part of the system from the beginning.

## Where this stands

The system in this post is still being built; nothing installs it with one command yet. Most of the building blocks are public and useful on their own; the map near the top marks which are still alpha or beta.

The main missing piece is integration. These projects already use one another—[Volt](https://github.com/elixir-volt/volt) uses [QuickBEAM](https://github.com/elixir-volt/quickbeam), [Exograph](https://github.com/elixir-vibe/exograph) uses [QuackDB](https://github.com/elixir-vibe/quackdb) and [ExAST](https://github.com/elixir-vibe/ex_ast), [HostKit](https://github.com/elixir-vibe/host_kit) consumes [ReleaseKit](https://github.com/elixir-vibe/release_kit) artifacts, and my projects run the quality tools on themselves—but they do not yet form one founder-facing product. The next phase is connecting what exists.

The most immediate product is OpenPencil Cloud: optional workspaces, synchronization, sharing, comments, and team component libraries, self-hostable, with local files still first-class. I also want to turn reference collection, alternative drafts, comparison, and iterative work with agents acting as designers into one coherent [OpenPencil](https://github.com/open-pencil/open-pencil) workflow, backed by a service that provides common access to language and vision models, image generation, and vectorization, something like [OpenRouter](https://openrouter.ai) focused on design, while still supporting users’ own credentials.

The path through [VuePencil](https://github.com/dannote/vue-pencil), the coding environment, and the rest of the platform then has to become a product. That includes the conventional building blocks founders currently get from [Supabase](https://supabase.com) or libraries such as [Better Auth](https://www.better-auth.com): authentication, accounts, files, notifications, and billing. Most of it will come from existing projects behind coherent Elixir APIs and defaults. And [Incant](https://github.com/elixir-vibe/incant) has to connect to the operational sources that already exist.

Some packages will merge, some abstractions will change after real use, and some experiments will fail. Publishing the pieces independently is how I find out which.

## How to help

Agents let me cover a lot of ground alone, but they cannot provide the variety of real use that a community can. Publishing each building block separately puts it in front of files, operating systems, and workflows I never tested. Bug reports expose my assumptions, and contributions take the projects beyond my own needs. Open source is how I develop the platform as much as how I distribute it.

So the best way to help is to use the projects in situations I have not considered, report what breaks, and tell me which parts are useful outside your own workflow. Contributions are welcome too.

## Funding the next phase

OpenPencil itself stays free and open source, and OpenPencil Cloud will be self-hostable. What I intend to build a company on is the services around it: hosted storage and collaboration, design references and other context for agents, illustration generation, and a design-API service, some of them in partnership with providers that already do this well.

Those services do not exist yet. Building them takes time, and most of the work runs on agents, so model tokens are a cost of their own. Until the services carry the work, I am looking for support.

<.article_callout>
<p>If you or your company would like to sponsor this work, or can provide model credits or infrastructure, write to me at <a href="mailto:hello@dannote.net">hello@dannote.net</a>.</p>
<p>Sponsorship can be general or tied to a package you depend on. Grants and partnerships with service providers are welcome too.</p>
<p>If you just want to chip in, there is <a href="https://web.tribute.tg/d/PXf">Tribute</a>.</p>
</.article_callout>
