/** @type {(e: MouseEvent | string) => any} */
function handleScroll(e) {
  e.preventDefault?.();
  /** @type {HTMLElement} */
  const el = e.target;
  const id = typeof e === "string" ? e : el.dataset.id;
  const targetEl = document.getElementById(id);
  if (!targetEl) {
    console.warn(`element with id of "${id}" not found`);
    return;
  }
  targetEl.scrollIntoView({
    behavior: "smooth",
    block: "start",
  });
}
