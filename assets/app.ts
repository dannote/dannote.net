declare global {
  interface ImportMeta {
    readonly hot?: {
      accept(): void;
    };
  }
}

document
  .querySelector<HTMLElement>("[data-current-year]")
  ?.replaceChildren(String(new Date().getFullYear()));

if (import.meta.hot) {
  import.meta.hot.accept();
}
