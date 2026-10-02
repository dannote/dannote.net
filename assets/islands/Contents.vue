<script setup lang="ts">
// The article's contents. Where there is room it is a sidebar: always open, its summary
// only a heading, out of the tab order. On narrower screens it sits above the article,
// collapsed until opened. Either way the entry for the section being read is current.
import { useMediaQuery } from "@vueuse/core";
import { useTemplateRef, watch } from "vue";
import { useCurrentSection } from "../composables/useCurrentSection";

interface Heading {
  id: string;
  text: string;
  level: number;
}

const props = defineProps<{ headings: Heading[] }>();

const breakpoint = getComputedStyle(document.documentElement)
  .getPropertyValue("--breakpoint-wide")
  .trim();
const wide = useMediaQuery(`(min-width: ${breakpoint})`);
const current = useCurrentSection(props.headings.map((heading) => heading.id));
const links = useTemplateRef<HTMLAnchorElement[]>("links");

// The sidebar is wholly on screen, so this scrolls only the sidebar, never the page.
watch(current, (id) => {
  if (wide.value) links.value?.find((link) => link.hash === `#${id}`)?.scrollIntoView({ block: "nearest" });
});
</script>

<template>
  <details :open="wide || undefined">
    <summary
      id="toc-title"
      class="cursor-pointer font-medium wide:cursor-default wide:list-none wide:[&::-webkit-details-marker]:hidden"
      :tabindex="wide ? -1 : undefined"
      @click="(event) => wide && event.preventDefault()"
    >
      Contents
    </summary>
    <div>
      <ol class="space-y-1 pt-2">
        <li v-for="heading in headings" :key="heading.id">
          <a
            ref="links"
            class="block border-l-2 border-transparent text-dim no-underline transition-colors duration-(--duration-hover) hover:text-copy current:border-accent current:text-copy"
            :class="heading.level > 2 ? 'pl-6' : 'pl-3'"
            :href="`#${heading.id}`"
            :aria-current="heading.id === current ? 'location' : undefined"
          >
            {{ heading.text }}
          </a>
        </li>
      </ol>
    </div>
  </details>
</template>
