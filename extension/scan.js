// This function runs inside the active tab only after the user presses Inspect.
// Keep it self-contained: chrome.scripting serializes the function body.
function scanPage() {
  const root = document.querySelector("article") || document.querySelector("main") || document.body;
  const links = Array.from(root.querySelectorAll("a[href]"))
    .filter(a => !a.closest("nav, header, footer, aside"))
    .slice(0, 2000);
  const observed = new Map();
  const http = [];
  const unlabeled = [];
  let external = 0;
  for (const a of links) {
    let url;
    try { url = new URL(a.getAttribute("href"), document.baseURI); }
    catch { continue; }
    if (!/^(https?:)$/.test(url.protocol) || url.origin === location.origin) continue;
    external++;
    // Never return query parameters, fragments, page contents, or link labels.
    const display = url.origin + url.pathname;
    observed.set(display, (observed.get(display) || 0) + 1);
    if (url.protocol === "http:" && http.length < 20) http.push(display);
    if (!(a.textContent.trim() || a.getAttribute("aria-label")?.trim() ||
          a.querySelector("img[alt]:not([alt=''])")) && unlabeled.length < 20) unlabeled.push(display);
  }
  const repeated = Array.from(observed.entries())
    .filter(([, count]) => count > 1).slice(0, 20)
    .map(([url, count]) => ({ url, count }));
  return { inspected: links.length, capped: links.length === 2000, external, http, unlabeled, repeated };
}
