import { persistentAtom } from "@nanostores/persistent";
import { atom, computed, effect, onMount } from "nanostores";

export type Theme = "light" | "dark";

const isTheme = (value: unknown): value is Theme => value === "light" || value === "dark";

// The head script in components/base_head.astral reads the same key before first paint.
export const $preference = persistentAtom<Theme | undefined>("theme", undefined, {
  decode: (value) => (isTheme(value) ? value : undefined),
  encode: (value) => value,
});

const darkScheme = matchMedia("(prefers-color-scheme: dark)");
const $systemTheme = atom<Theme>(darkScheme.matches ? "dark" : "light");

onMount($systemTheme, () => {
  const update = () => $systemTheme.set(darkScheme.matches ? "dark" : "light");
  update();
  darkScheme.addEventListener("change", update);
  return () => darkScheme.removeEventListener("change", update);
});

export const $theme = computed(
  [$preference, $systemTheme],
  (preference, system): Theme => preference ?? system,
);

export function toggleTheme(): void {
  $preference.set($theme.get() === "dark" ? "light" : "dark");
}

// CSS renders the theme, the toggle, and its icon from `data-theme`.
const stopRoot = effect($preference, (preference) => {
  const root = document.documentElement;
  if (preference) root.dataset.theme = preference;
  else delete root.dataset.theme;
});

const toggles = document.querySelectorAll<HTMLButtonElement>("[data-theme-toggle]");

const stopLabels = effect($theme, (theme) => {
  const label = `Switch to ${theme === "dark" ? "light" : "dark"} theme`;

  for (const button of toggles) {
    button.setAttribute("aria-label", label);
    button.title = label;
  }
});

const clicks = new AbortController();
for (const button of toggles)
  button.addEventListener("click", toggleTheme, { signal: clicks.signal });

if (import.meta.hot) {
  import.meta.hot.dispose(() => {
    stopRoot();
    stopLabels();
    clicks.abort();
  });
}
