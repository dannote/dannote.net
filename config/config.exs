import Config

config :mdex_native, syntax_highlighter: :lumis

# PhoenixIconify 0.3 does not scan Markdown files for literal icon names.
config :phoenix_iconify, extra_icons: ["simple-icons:github", "simple-icons:x"]

config :volt,
  format: [
    print_width: 100,
    semi: true,
    single_quote: false,
    trailing_comma: :all,
    arrow_parens: :always
  ],
  lint: [
    plugins: [:typescript],
    tsgolint: System.find_executable("tsgolint"),
    rules: %{
      "correctness" => :deny,
      "no-debugger" => :deny,
      "eqeqeq" => :deny,
      "typescript/no-explicit-any" => :warn
    }
  ],
  sources: ["**/*.{js,ts,jsx,tsx,vue}"],
  tailwind: [
    css: "assets/styles.css",
    sources: [
      %{base: "pages/", pattern: "**/*.{astral,md,html}"},
      %{base: "layouts/", pattern: "**/*.{astral,html}"},
      %{base: "components/", pattern: "**/*.astral"},
      %{base: "content/", pattern: "**/*.md"},
      %{base: "assets/", pattern: "**/*.{vue,ts,tsx,js,jsx}"}
    ]
  ]
