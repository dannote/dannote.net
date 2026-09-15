[
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}",
    "assets/**/*.{js,ts,jsx,tsx}"
  ],
  excludes: ["assets/.astral/**/*"],
  plugins: [Volt.Formatter]
]
