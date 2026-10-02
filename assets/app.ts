import { useEventListener, useMediaQuery } from "@vueuse/core";
import { effectScope, watchEffect } from "vue";
import "./theme";
import "./x-posts";

// The contents sidebar is open where there is room for it, collapsed above the article otherwise.
// As a sidebar it stays open: its summary is only a heading there, out of the tab order.
const scope = effectScope();

scope.run(() => {
  const contents = document.querySelector<HTMLDetailsElement>(".article-toc details");
  const breakpoint = getComputedStyle(document.documentElement)
    .getPropertyValue("--breakpoint-wide")
    .trim();
  const wide = useMediaQuery(`(min-width: ${breakpoint})`);

  const summary = contents?.querySelector("summary");

  watchEffect(() => {
    if (contents) contents.open = wide.value;
    if (summary) summary.tabIndex = wide.value ? -1 : 0;
  });

  useEventListener(summary, "click", (event) => {
    if (wide.value) event.preventDefault();
  });
});

if (import.meta.hot) {
  import.meta.hot.accept();
  import.meta.hot.dispose(() => scope.stop());
}
