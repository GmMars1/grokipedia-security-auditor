// Run with: node extension/test-scan.js
const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const source = fs.readFileSync(__dirname + "/scan.js", "utf8");
function link(href, label = "source", inNav = false) {
  return {
    getAttribute: key => key === "href" ? href : null,
    textContent: label,
    closest: () => inNav ? {} : null,
    querySelector: () => null
  };
}
const anchors = [
  link("https://example.org/paper?token=secret#page", ""),
  link("https://example.org/paper?token=another"),
  link("http://source.test/a"),
  link("https://site.test/local"),
  link("https://hidden.test/a", "source", true)
];
const root = { querySelectorAll: () => anchors };
const context = {
  URL,
  location: { origin: "https://site.test" },
  document: { querySelector: () => root, body: root, baseURI: "https://site.test/page" }
};
vm.createContext(context);
vm.runInContext(source + "\nthis.result = scanPage();", context);
const result = JSON.parse(JSON.stringify(context.result));
assert.equal(result.external, 3);
assert.equal(result.inspected, 4);
assert.deepEqual(result.http, ["http://source.test/a"]);
assert.deepEqual(result.unlabeled, ["https://example.org/paper"]);
assert.deepEqual(result.repeated, [{url: "https://example.org/paper", count: 2}]);
assert.ok(!JSON.stringify(result).includes("secret"));
console.log("Citation inspection checks passed");
