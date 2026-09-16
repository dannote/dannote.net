[
  inputs: [
    "{mix,.formatter,astral.config}.exs",
    "{pages,layouts,components}/**/*.astral",
    "{config,lib,test}/**/*.{ex,exs}",
    "assets/**/*.{js,ts,jsx,tsx}"
  ],
  excludes: ["assets/.astral/**/*"],
  plugins: [Astral.Formatter, Volt.Formatter]
]
