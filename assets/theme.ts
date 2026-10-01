type Theme = "light" | "dark";

const system = matchMedia("(prefers-color-scheme: dark)");
const listeners = new AbortController();
let preference: Theme | undefined;

function readPreference(): Theme | undefined {
  try {
    const stored = localStorage.getItem("theme");
    return stored === "light" || stored === "dark" ? stored : undefined;
  } catch {
    return undefined;
  }
}

function currentTheme(): Theme {
  return preference ?? (system.matches ? "dark" : "light");
}

// CSS renders the theme, the toggle, and its icon from `data-theme`; this only keeps
// the attribute and the toggle's label in sync.
function applyTheme(): void {
  const root = document.documentElement;

  if (preference) root.dataset.theme = preference;
  else delete root.dataset.theme;

  const label = `Switch to ${currentTheme() === "dark" ? "light" : "dark"} theme`;

  for (const button of document.querySelectorAll<HTMLButtonElement>("[data-theme-toggle]")) {
    button.setAttribute("aria-label", label);
    button.title = label;
  }
}

preference = readPreference();
applyTheme();

for (const button of document.querySelectorAll<HTMLButtonElement>("[data-theme-toggle]")) {
  button.addEventListener(
    "click",
    () => {
      preference = currentTheme() === "dark" ? "light" : "dark";
      try {
        localStorage.setItem("theme", preference);
      } catch {
        // Keep the current-page preference when browser storage is unavailable.
      }
      applyTheme();
    },
    { signal: listeners.signal },
  );
}

system.addEventListener("change", applyTheme, { signal: listeners.signal });
window.addEventListener(
  "storage",
  (event) => {
    if (event.key === "theme" || event.key === null) {
      preference = readPreference();
      applyTheme();
    }
  },
  { signal: listeners.signal },
);

if (import.meta.hot) {
  import.meta.hot.dispose(() => listeners.abort());
}
