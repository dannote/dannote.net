import "./theme";

const contents = document.querySelector<HTMLDetailsElement>(".article-toc details");
const breakpoint = getComputedStyle(document.documentElement)
  .getPropertyValue("--breakpoint-wide")
  .trim();
const wide = matchMedia(`(min-width: ${breakpoint})`);
const syncContents = () => {
  if (contents) contents.open = wide.matches;
};
syncContents();
wide.addEventListener("change", syncContents);

if (import.meta.hot) {
  import.meta.hot.accept();
  import.meta.hot.dispose(() => wide.removeEventListener("change", syncContents));
}
