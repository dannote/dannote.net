defmodule Blog.SocialImagesTest do
  use ExUnit.Case, async: true

  alias Blog.SocialImages

  test "registers only published article cards plus the default" do
    entries =
      for draft <- [false, true] do
        %Astral.Entry{
          route_path: "/writing/#{draft}/",
          data: %{title: "Example", description: "Summary", date: ~D[2026-09-16], draft: draft}
        }
      end

    site = %Astral.Site{config: Astral.Config.new(), entries: %{articles: entries}}
    routes = SocialImages.routes(site, [])
    assert Enum.map(routes, & &1.path) == ["/social/site.png", "/social/writing/false.png"]
    assert Enum.all?(routes, &(&1.content_type == "image/png"))
  end

  test "renders long Cyrillic titles using bundled fonts" do
    title = String.duplicate("Инструменты для разработчиков и агентов. ", 8)

    assert {:ok, png} =
             SocialImages.render(title, "Описание проекта — без внешних сервисов.", "Заметка")

    assert <<137, 80, 78, 71, 13, 10, 26, 10, 13::32, "IHDR", 1200::32, 630::32, _::binary>> = png
  end

  test "route renderer returns PNG bytes and ignores unrelated routes" do
    site = %Astral.Site{config: Astral.Config.new(), entries: %{articles: []}}
    [route] = SocialImages.routes(site, [])
    assert {:ok, png, "image/png"} = SocialImages.render_route(route, site, [])
    assert byte_size(png) > 1000
    assert SocialImages.render_route(%Astral.Route{kind: :other}, site, []) == nil
  end
end
