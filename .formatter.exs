[
  inputs: [
    "{mix,.formatter,astral.config}.exs",
    "{pages,layouts,components}/**/*.astral",
    "{config,lib,test}/**/*.{ex,exs}",
    "assets/**/*.{js,ts,jsx,tsx}"
  ],
  excludes: ["assets/.astral/**/*"],
  plugins: [Astral.Formatter, Volt.Formatter],
  volt: [
    print_width: 100,
    semi: true,
    single_quote: false,
    trailing_comma: :all,
    arrow_parens: :always
  ]
]
