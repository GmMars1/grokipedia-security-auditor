// Run with: node extension/test-popup.js
const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");

class Element {
  constructor() { this.children = []; this.textContent = ""; this.hidden = false; this.disabled = false; }
  replaceChildren() { this.children = []; }
  append(child) { this.children.push(child); }
  addEventListener(event, handler) { this.handler = handler; }
}
const ids = ["scan", "status", "results", "summary", "http", "unlabeled", "repeated"];
const elements = Object.fromEntries(ids.map(id => [id, new Element()]));
const unsafe = '<img src=x onerror=alert(1)>';
const context = {
  document: {
    getElementById: id => elements[id],
    createElement: () => new Element()
  },
  chrome: {
    tabs: { query: async () => [{ id: 1 }] },
    scripting: { executeScript: async ({ func }) => {
      assert.equal(typeof func, "function");
      return [{ result: { external: 1, inspected: 1, capped: false,
        http: [`http://example.test/${unsafe}`], unlabeled: [], repeated: [] } }];
    } }
  }
};
vm.createContext(context);
vm.runInContext(fs.readFileSync(__dirname + "/scan.js", "utf8"), context);
vm.runInContext(fs.readFileSync(__dirname + "/popup.js", "utf8"), context);

(async () => {
  await elements.scan.handler();
  assert.equal(elements.results.hidden, false);
  assert.equal(elements.http.children[0].textContent, `http://example.test/${unsafe}`);
  assert.equal(elements.http.children[0].children.length, 0); // never parse URL as HTML
  assert.equal(elements.scan.disabled, false);
  context.chrome.scripting.executeScript = async () => { throw new Error("injection blocked"); };
  await elements.scan.handler();
  assert.equal(elements.results.hidden, true); // do not show a stale report
  assert.match(elements.status.textContent, /cannot be inspected/);
  console.log("Popup rendering and failure checks passed");
})().catch(error => { console.error(error); process.exitCode = 1; });
