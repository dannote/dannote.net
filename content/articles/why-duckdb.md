---
title: "Why DuckDB"
description: "Where DuckDB fits alongside Postgres, and what QuackDB adds for Elixir."
date: 2026-06-07
language: en
kind: Note
draft: false
sources:
  - https://x.com/dan_note/status/2063414257308614713
---

I’m increasingly convinced that [DuckDB](https://duckdb.org) is becoming one of the best storage choices for hobby to medium-sized projects.

Postgres is still the obvious default for highly concurrent OLTP systems, but many small and medium products are read-heavy, append-heavy, analytical, or operated by a small team. For those workloads, DuckDB’s columnar execution model, vectorized engine, rich SQL surface, and embedded/local-first deployment model can be a much better fit.

I intend to use DuckDB as the primary storage layer for the platform I’m building, so QuackDB focuses on the parts I need in a real Elixir app: supervision, connection pooling, Ecto, fast append paths, dataframes, telemetry, and helpers for DuckDB’s analytical SQL.

[QuackDB 0.5](https://github.com/elixir-vibe/quackdb/releases/tag/v0.5.0) focuses on making the Ecto and analytical side much more complete:

- append through Ecto with defaults and returning
- using an Ecto repo directly with QuackDB native query/append APIs
- advanced join patterns, including semi/anti and `ASOF`-style queries
- DuckDB star/`COLUMNS` expressions in SQL and Ecto
- broader `LIST`/`MAP`/`STRUCT` helpers
- `PIVOT`, `UNPIVOT`, `GROUPING SETS`, `ROLLUP`, and `CUBE` builders
- `LIST` lambdas in Ecto with `fn` syntax and `case_when`
- better nullable/schema type handling for append-heavy workloads

QuackDB also continues to cover the broader integration surface: supervised DuckDB, DBConnection/Ecto, native append, Explorer dataframes, Table.Reader results, Geo/WKB, telemetry, managed DuckDB binaries, and DuckDB-specific SQL helpers.

## Update, August 2026

DuckLabs [is joining AWS](https://x.com/duckdb/status/2092598676439044577), with DuckDB and the rest of the Duck Stack staying MIT-licensed under the DuckDB Foundation. I’m now pretty confident that DuckDB is the right bet as the primary storage engine for the platform I’m building.

QuackDB, the Ecto adapter for DuckDB’s Quack protocol, is in good shape. I’ve spent a lot of effort polishing the DSL and internals for scenarios like bulk inserts, and I’m already using it in production across several projects.
