import { useScroll, useWindowSize } from "@vueuse/core";
import { computed } from "vue";

// The id of the section being read: the last heading above the top third of the
// window, or the last one at the bottom of the page, however short its section is.
// Heading positions are read on each scroll; there are only a few dozen.
export function useCurrentSection(ids: string[]) {
  const headings = ids.flatMap((id) => document.getElementById(id) ?? []);
  const { y, arrivedState } = useScroll(window);
  const { height } = useWindowSize();

  return computed(() => {
    void y.value;
    if (arrivedState.bottom) return headings.at(-1)?.id;
    return headings.findLast((heading) => heading.getBoundingClientRect().top <= height.value / 3)
      ?.id;
  });
}
