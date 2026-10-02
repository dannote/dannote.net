import { useIntersectionObserver, useMediaQuery } from "@vueuse/core";
import { effectScope, watchEffect } from "vue";
import "./theme";
import "./x-posts";

// The contents sidebar is open where there is room for it, collapsed above the article otherwise.
const scope = effectScope();

scope.run(() => {
  const contents = document.querySelector<HTMLDetailsElement>(".article-toc details");
  const breakpoint = getComputedStyle(document.documentElement)
    .getPropertyValue("--breakpoint-wide")
    .trim();
  const wide = useMediaQuery(`(min-width: ${breakpoint})`);

  watchEffect(() => {
    if (contents) contents.open = wide.value;
  });

  // Figures' ambient backgrounds stop drifting while out of view, so a long post
  // doesn't keep every one of them animating.
  const ambients = [...document.querySelectorAll<HTMLElement>(".figure-ambient")];
  useIntersectionObserver(ambients, (entries) => {
    for (const { target, isIntersecting } of entries) {
      if (target instanceof HTMLElement) target.toggleAttribute("data-offscreen", !isIntersecting);
    }
  });
});

if (import.meta.hot) {
  import.meta.hot.accept();
  import.meta.hot.dispose(() => scope.stop());
}
