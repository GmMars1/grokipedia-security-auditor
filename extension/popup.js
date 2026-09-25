const button = document.getElementById("scan");
const status = document.getElementById("status");
const results = document.getElementById("results");

function list(id, items) {
  const element = document.getElementById(id);
  element.replaceChildren();
  if (!items.length) {
    const item = document.createElement("li");
    item.textContent = "None found";
    element.append(item);
    return;
  }
  for (const value of items) {
    const item = document.createElement("li");
    item.textContent = typeof value === "string" ? value : `${value.url} (${value.count} times)`;
    element.append(item);
  }
}

button.addEventListener("click", async () => {
  button.disabled = true;
  results.hidden = true;
  status.textContent = "Inspecting current page…";
  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    if (!tab?.id) throw new Error("No active tab is available.");
    const [{ result }] = await chrome.scripting.executeScript({
      target: { tabId: tab.id }, func: scanPage
    });
    if (!result) throw new Error("Could not inspect this page.");
    document.getElementById("summary").textContent =
      `${result.external} outbound links among ${result.inspected} inspected links.` +
      (result.capped ? " Inspection stopped after 2,000 links." : "");
    list("http", result.http);
    list("unlabeled", result.unlabeled);
    list("repeated", result.repeated);
    results.hidden = false;
    status.textContent = "Inspection complete. Results stay in this popup.";
  } catch (error) {
    status.textContent = "This page cannot be inspected. Try a regular website tab.";
  } finally {
    button.disabled = false;
  }
});
