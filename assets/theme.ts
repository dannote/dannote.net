import { usePreferredDark, useEventListener, useStorage } from "@vueuse/core";
import { computed, effectScope, watchEffect } from "vue";

export type Theme = "light" | "dark";

const isTheme = (value: unknown): value is Theme => value === "light" || value === "dark";

const scope = effectScope();

export const { preference, theme } = scope.run(() => {
  // The head script in components/site/head.astral reads the same key before first paint.
  const preference = useStorage<Theme | null>("theme", null, undefined, {
    serializer: { read: (value) => (isTheme(value) ? value : null), write: (value) => value ?? "" },
  });

  const prefersDark = usePreferredDark();
  const theme = computed<Theme>(() => preference.value ?? (prefersDark.value ? "dark" : "light"));

  // CSS renders the theme, the toggle, and its icon from `data-theme`.
  watchEffect(() => {
    const root = document.documentElement;
    if (preference.value) root.dataset.theme = preference.value;
    else delete root.dataset.theme;
  });

  const toggles = [...document.querySelectorAll<HTMLButtonElement>("[data-theme-toggle]")];

  watchEffect(() => {
    const label = `Switch to ${theme.value === "dark" ? "light" : "dark"} theme`;

    for (const button of toggles) {
      button.setAttribute("aria-label", label);
      button.title = label;
    }
  });

  useEventListener(toggles, "click", () => {
    preference.value = theme.value === "dark" ? "light" : "dark";
  });

  return { preference, theme };
})!;

if (import.meta.hot) import.meta.hot.dispose(() => scope.stop());
