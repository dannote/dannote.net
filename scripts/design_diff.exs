import Skia, only: [canvas: 2, clear: 2, rect: 2, circle: 2, text: 3, to_png: 1]
alias Skia.{Font, Typeface}

{:ok, regular} = :blog |> Application.app_dir("priv/fonts/NotoSans-Regular.ttf") |> Typeface.load_path()
{:ok, bold} = :blog |> Application.app_dir("priv/fonts/NotoSans-Bold.ttf") |> Typeface.load_path()

# A small "card" screen, drawn twice. The second has the changes a design review
# would catch: a tinted surface, a renamed title, a rounder and darker button.
draw = fn %{surface: surface, title: title, button: button, radius: radius} ->
  canvas(480, 300)
  |> clear("#E9E6DF")
  |> rect(x: 40, y: 32, width: 400, height: 236, radius: 16, fill: surface)
  |> circle(x: 84, y: 84, radius: 20, fill: "#D9D4C7")
  |> text(title, x: 120, y: 66, size: 22, fill: "#15161A", font: Font.new(bold))
  |> text("Updated 2 min ago", x: 120, y: 96, size: 14, fill: "#555961", font: Font.new(regular))
  |> text("A silent patch broke the debugging port. The team is looking into it.",
    x: 64, y: 134, width: 352, size: 15, fill: "#15161A", font: Font.new(regular), line_height: 22)
  |> rect(x: 64, y: 206, width: 132, height: 40, radius: radius, fill: button)
  |> text("Reply", x: 64, y: 216, width: 132, size: 15, fill: "#FFFFFF", font: Font.new(bold), align: :center)
  |> to_png()
end

{:ok, before} = draw.(%{surface: "#FFFFFF", title: "Card / Header", button: "#2563EB", radius: 8})
{:ok, after_} = draw.(%{surface: "#F0F0F0", title: "Card / Header v2", button: "#1D4ED8", radius: 20})

File.write!("assets/images/figma/diff-before.png", before)
File.write!("assets/images/figma/diff-after.png", after_)

{:ok, a} = Image.from_binary(before)
{:ok, b} = Image.from_binary(after_)
{:ok, metric, diff} = Image.compare(a, b, difference_color: :red, difference_boost: 2.0)
Image.write!(diff, "assets/images/figma/diff-result.png")
IO.puts("metric: #{inspect(metric)}")
