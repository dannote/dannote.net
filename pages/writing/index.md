---
title: Writing
description: Essays and notes on coding agents, design tools, and the systems underneath them.
---

# Writing

I write about building tools that let people and agents understand what they are working on—not just generate more code. [Subscribe via Atom](/feed.xml).

<section aria-labelledby="essays-title">
  <h2 id="essays-title">Essays</h2>
  <div :for={article <- @site |> Astral.Collection.entries(:articles) |> Astral.Collection.published() |> Astral.Collection.sort_by_date(:desc)} :if={Map.get(article.data, :kind, "Essay") == "Essay"} class="border-t border-copy/20 py-5">
    <.writing_entry entry={article} />
    <.more_link href={article.route_path}>Read the essay</.more_link>
  </div>
</section>

<section aria-labelledby="notes-title">
  <h2 id="notes-title">Notes</h2>
  <p>Selected longer posts, first published on X. Original dates and source links are preserved.</p>
  <ul class="list-none pl-0">
    <li :for={article <- @site |> Astral.Collection.entries(:articles) |> Astral.Collection.published() |> Astral.Collection.sort_by_date(:desc)} :if={Map.get(article.data, :kind, "Essay") == "Note"} class="border-t border-copy/20 py-4 pl-0">
      <.writing_entry entry={article} />
    </li>
  </ul>
</section>
