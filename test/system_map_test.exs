defmodule Blog.SystemMapTest do
  use ExUnit.Case, async: true

  test "renders the diagram outside the client island for readers without JavaScript" do
    config = Astral.Config.new(root: File.cwd!())
    Astral.Islands.Registry.start(%Astral.Site{config: config, mode: :dev})

    try do
      assert {:ok, html} =
               Astral.Template.render_file("components/system_map.astral", %{}, config)

      document = Floki.parse_fragment!(html)
      assert [_] = Floki.find(document, "#system-map-drawing svg")
      assert Floki.find(document, "[data-astral-island] svg") == []
      assert Floki.find(document, "template svg") == []
      assert Floki.text(document) =~ "Product hypothesis"
      assert Floki.text(document) =~ "Evidence-backed next step"

      assert Floki.attribute(document, "[data-astral-island]", "data-astral-props") ==
               [Jason.encode!(%{target: "system-map-drawing"})]
    after
      Astral.Islands.Registry.stop()
    end
  end
end
