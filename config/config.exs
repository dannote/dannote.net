import Config

# tsgolint, the TypeScript-aware linter Volt runs in `mix ci`, is an npm dev dependency.
# Its native binary lives in a package named for the platform it was built for.
tsgolint_platform =
  case :erlang.system_info(:system_architecture) |> to_string() |> String.split("-") do
    ["aarch64", _, "darwin" <> _ | _] -> "darwin-arm64"
    ["x86_64", _, "darwin" <> _ | _] -> "darwin-x64"
    ["aarch64" | _] -> "linux-arm64"
    _ -> "linux-x64"
  end

config :mdex_native, syntax_highlighter: :lumis

config :volt,
  lint: [
    tsgolint:
      Path.expand("../node_modules/@oxlint-tsgolint/#{tsgolint_platform}/tsgolint", __DIR__),
    rules: %{
      "correctness" => :deny,
      "no-debugger" => :deny,
      "eqeqeq" => :deny,
      "typescript/no-explicit-any" => :warn
    }
  ],
  sources: ["**/*.{js,ts,jsx,tsx}"],
  # In development, a page whose HTML changed is patched in place instead of
  # reloaded. Mounted islands are left alone, and re-render when their props change.
  server: [morph: [preserve: "[data-astral-island]"]],
  tailwind: [
    css: "assets/styles.css",
    sources: [
      %{base: "pages/", pattern: "**/*.{astral,md,html}"},
      %{base: "layouts/", pattern: "**/*.{astral,html}"},
      %{base: "components/", pattern: "**/*.astral"},
      %{base: "content/", pattern: "**/*.md"},
      %{base: "assets/", pattern: "**/*.{ts,tsx,js,jsx}"}
    ]
  ]
