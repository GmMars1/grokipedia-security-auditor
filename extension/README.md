# GrokiPedia Citation Inspector (prototype)

An on-demand Manifest V3 extension for inspecting outbound links in the current page's article or main content. It reports HTTP links, links without a readable label, and repeated destinations. These checks do **not** determine whether a link works, a domain is trustworthy, or a claim is true. This prototype does not implement the framework scanner or trust scores mentioned in the repository's older configuration.

## Install locally

1. On desktop Chrome, open `chrome://extensions`, enable Developer mode, and select **Load unpacked**.
2. Select this `extension/` directory.
3. Open an article, click the extension icon, then **Inspect this page**.

Permissions: `activeTab` grants temporary access to the page the user selects; `scripting` runs the inspection after the user presses the button. There are no persistent host permissions, remote requests, analytics, storage, accounts, or third-party libraries. Restricted Chrome pages cannot be inspected. The scan examines up to 2,000 links and displays at most 20 per finding category. It strips query strings and fragments from displayed URLs. Results vanish when the popup closes. See [Privacy](PRIVACY.md).

## Scope and validation

`node --check extension/scan.js && node --check extension/popup.js` validates JavaScript syntax. Load unpacked in desktop Chrome for the browser acceptance check. Inspect an article with an HTTP external link, a link containing only an image with no alt text, and repeated outbound links; confirm the three lists and verify in DevTools Network that the extension makes no requests. Chrome internal pages should show a friendly error. No Chrome Web Store submission has been made.
