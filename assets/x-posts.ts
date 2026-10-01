import { effect } from "nanostores";
import { $theme, type Theme } from "./theme";

// Blog.Markdown.XPosts wraps each quoted post in `.x-post`. Once one nears the viewport,
// X's embed replaces the quote, and it is rebuilt when the theme changes: the embed is
// an iframe that page CSS can't restyle.

interface Twttr {
  ready(callback: (twttr: Twttr) => void): void;
  widgets: {
    createTweet(
      id: string,
      target: HTMLElement,
      options: { theme: Theme; dnt: boolean; conversation: "none" },
    ): Promise<HTMLElement | undefined>;
  };
}

declare global {
  interface Window {
    twttr?: Twttr;
  }
}

let widgets: Promise<Twttr> | undefined;

function loadWidgets(): Promise<Twttr> {
  widgets ??= new Promise((resolve, reject) => {
    const script = document.createElement("script");
    script.src = "https://platform.twitter.com/widgets.js";
    script.async = true;
    script.onload = () => window.twttr?.ready(resolve);
    script.onerror = reject;
    document.head.append(script);
  });

  return widgets;
}

async function embed(post: HTMLElement, theme: Theme): Promise<void> {
  const link = post.querySelector<HTMLAnchorElement>(
    ":scope > blockquote > p:last-child > a:last-child",
  );
  const id = link?.pathname.match(/\/status\/(\d+)/)?.[1];
  if (!id) return;

  const twttr = await loadWidgets();
  const target = document.createElement("div");
  target.className = "x-post-loading";
  post.append(target);

  const rendered = await twttr.widgets.createTweet(id, target, {
    theme,
    dnt: true,
    conversation: "none",
  });

  // A newer theme may have started another embed meanwhile; keep only the latest.
  if (!rendered || $theme.get() !== theme) {
    target.remove();
    return;
  }

  post.querySelector(":scope > blockquote")?.setAttribute("hidden", "");
  post.querySelector(":scope > [data-x-embed]")?.remove();
  target.className = "";
  target.dataset.xEmbed = "";
}

const stops: (() => void)[] = [];

const observer = new IntersectionObserver(
  (entries) => {
    for (const { isIntersecting, target } of entries) {
      if (!isIntersecting || !(target instanceof HTMLElement)) continue;
      observer.unobserve(target);
      stops.push(effect($theme, (theme) => void embed(target, theme).catch(() => {})));
    }
  },
  { rootMargin: "400px" },
);

for (const post of document.querySelectorAll(".x-post")) observer.observe(post);

if (import.meta.hot) {
  import.meta.hot.dispose(() => {
    observer.disconnect();
    for (const stop of stops) stop();
  });
}
