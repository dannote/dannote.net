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

function applyTheme(): void {
  const theme = currentTheme();
  document.documentElement.style.colorScheme = theme;

  for (const button of document.querySelectorAll<HTMLButtonElement>("[data-theme-toggle]")) {
    button.hidden = false;
    const label = `Switch to ${theme === "dark" ? "light" : "dark"} theme`;
    button.setAttribute("aria-label", label);
    button.title = label;

    for (const icon of button.querySelectorAll<HTMLElement>("[data-theme-icon]")) {
      icon.hidden = icon.dataset.themeIcon === theme;
    }
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
