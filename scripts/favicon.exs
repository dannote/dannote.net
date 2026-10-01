# Draws the site's icons from the portrait in public/images/.
#
#     mix run scripts/favicon.exs
#
# The browser-tab icon is the photo cropped to a circle with transparent corners,
# drawn at 64 × 64 so it stays sharp at the 32-pixel size high-density screens use.
# The Apple touch icon stays square: iOS and macOS mask it to their own rounded
# shape, and a transparent circle would get black corners there.
photo = Image.open!("public/images/danila-poyarkov.jpg")

{:ok, round} = Image.avatar(photo, size: 64, shape: :circle)
Image.write!(round, "public/favicon.png")

{:ok, square} = Image.thumbnail(photo, 180, crop: :center)
Image.write!(square, "public/apple-touch-icon.png", strip_metadata: true)

IO.puts("wrote public/favicon.png and public/apple-touch-icon.png")
