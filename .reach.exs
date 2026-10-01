# Architecture policy for this site, checked by `mix reach.check --arch` in `mix ci`.
# Blog.Site holds facts about the site; plugins render routes from them; previews
# fetch link metadata at build time. Nothing below a layer may reach back up.
[
  layers: [
    site: "Blog.Site",
    highlight: "Blog.Highlight",
    plugins: ["Blog.SocialImages", "Blog.Markdown.*"],
    previews: "Blog.LinkPreview*"
  ],
  deps: [
    forbidden: [
      {:site, :plugins},
      {:site, :previews},
      {:highlight, :plugins},
      {:highlight, :previews},
      {:plugins, :previews}
    ]
  ]
]
