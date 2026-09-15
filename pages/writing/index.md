---
title: Writing
description: Notes and longer articles about the things I’m building.
---

# Writing

Notes and longer articles about the things I’m building. [Subscribe via Atom](/feed.xml).

<ul>
  <li :for={article <- @site |> Astral.Collection.entries(:articles) |> Astral.Collection.published() |> Astral.Collection.sort_by_date(:desc)}>
    <h2><a href={article.route_path}>{article.data.title}</a></h2>
    <small class="mt-1 block text-dim"><.formatted_date value={article.data.date} lang={article.data.language} /></small>
    <p>{article.data.description}</p>
  </li>
</ul>
