import { useMediaQuery } from "@vueuse/core";
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
});

if (import.meta.hot) {
  import.meta.hot.accept();
  import.meta.hot.dispose(() => scope.stop());
}
