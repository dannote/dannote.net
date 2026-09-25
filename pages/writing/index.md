---
title: Writing
description: Essays and notes on coding agents, design tools, and the systems underneath them.
---

# Writing

I write about building tools that let people and agents understand what they are working on—not just generate more code.

<section aria-labelledby="essays-title">
  <h2 id="essays-title">Essays</h2>
  <ul class="not-prose my-4 list-none space-y-4 p-0">
    <li :for={article <- @site |> Astral.Collection.entries(:articles) |> Astral.Collection.published() |> Astral.Collection.sort_by_date(:desc)} :if={Map.get(article.data, :kind, "Essay") == "Essay"}>
      <.writing_entry entry={article} />
    </li>
  </ul>
</section>

<section aria-labelledby="notes-title">
  <h2 id="notes-title">Notes</h2>
  <ul class="not-prose my-4 list-none space-y-4 p-0">
    <li :for={article <- @site |> Astral.Collection.entries(:articles) |> Astral.Collection.published() |> Astral.Collection.sort_by_date(:desc)} :if={Map.get(article.data, :kind, "Essay") == "Note"}>
      <.writing_entry entry={article} />
    </li>
  </ul>
</section>
