# Draws the before and after cards for the visual diff figure and diffs them.
#
#     mix run scripts/design_diff.exs
#
# Output goes to assets/images/figma/. The cards are drawn at 2x (960 × 600) so
# text stays crisp when the figure shows them at half size. They use TeX Gyre Heros,
# the free Helvetica the social cards use, so every drawing on the site matches the
# page's Helvetica Neue; see Blog.SocialImages for why that font.
import Skia, only: [canvas: 2, clear: 2, rect: 2, circle: 2, text: 3, to_png: 1]
alias Skia.{Font, Typeface}

typeface = fn file ->
  {:ok, face} = :blog |> Application.app_dir("priv/fonts/#{file}") |> Typeface.load_path()
  face
end

regular = Font.new(typeface.("TeXGyreHeros-Regular.otf"))
bold = Font.new(typeface.("TeXGyreHeros-Bold.otf"))

ink = "#15161A"
muted = "#6B6F76"
rule = "#E4E1DA"

# Text without a width is anchored at its baseline. Labels are centered on a point
# by measuring their advance and placing the baseline half a cap height below it.
cap = 0.72

centered = fn doc, label, cx, cy, size, font, fill ->
  {:ok, %{width: w}} = Skia.measure_text(label, font: font, size: size)
  text(doc, label, x: cx - w / 2, y: round(cy + size * cap / 2), size: size, fill: fill, font: font)
end

draw = fn %{surface: surface, title: title, button: button, radius: radius} ->
  canvas(960, 600)
  |> clear("#ECEAE4")
  # card
  |> rect(x: 80, y: 64, width: 800, height: 472, radius: 24, fill: surface, stroke: rule, stroke_width: 2)
  # avatar, centered on y = 152, with its monogram
  |> circle(x: 164, y: 152, radius: 36, fill: "#DCD7CB")
  |> centered.("DP", 164, 152, 24, bold, "#7A7262")
  # header: title and subtitle as one block centered on the avatar
  |> text(title, x: 224, y: 144, size: 40, fill: ink, font: bold)
  |> text("Updated 2 min ago", x: 224, y: 184, size: 26, fill: muted, font: regular)
  # body
  |> text("A silent patch broke the debugging port. The team is looking into it and will post an update here.",
    x: 128, y: 236, width: 704, size: 28, fill: ink, font: regular, line_height: 42)
  # divider
  |> rect(x: 128, y: 372, width: 704, height: 2, fill: rule)
  # actions, labels centered in their buttons
  |> rect(x: 128, y: 420, width: 232, height: 80, radius: radius, fill: button)
  |> centered.("Reply", 244, 460, 28, bold, "#FFFFFF")
  |> rect(x: 384, y: 420, width: 232, height: 80, radius: 16, stroke: "#C9C4B8", stroke_width: 2)
  |> centered.("Remind me", 500, 460, 28, regular, ink)
  |> to_png()
end

{:ok, before} = draw.(%{surface: "#FFFFFF", title: "Card / Header", button: "#2563EB", radius: 16})
{:ok, after_} = draw.(%{surface: "#F3F2EF", title: "Card / Header v2", button: "#1D4ED8", radius: 40})

File.write!("assets/images/figma/diff-before.png", before)
File.write!("assets/images/figma/diff-after.png", after_)

{:ok, a} = Image.from_binary(before)
{:ok, b} = Image.from_binary(after_)
{:ok, metric, diff} = Image.compare(a, b, difference_color: :red, difference_boost: 2.0)
Image.write!(diff, "assets/images/figma/diff-result.png")
IO.puts("difference metric: #{Float.round(metric, 3)}")
