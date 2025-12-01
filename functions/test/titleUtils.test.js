const assert = require("assert");
const {objectToMap, isTitleChanged} = require("../lib/titleUtils");

// objectToMap should handle undefined gracefully
(() => {
  const map = objectToMap();
  assert.strictEqual(map.size, 0);
})();

// objectToMap should convert plain object to Map
(() => {
  const map = objectToMap({"1": "1", "2": "0"});
  assert.strictEqual(map.get("1"), "1");
  assert.strictEqual(map.get("2"), "0");
})();

// isTitleChanged should detect differences and equality correctly
(() => {
  const current = new Map([["1", "1"], ["2", "0"]]);
  const same = {"1": "1", "2": "0"};
  const different = {"1": "1", "2": "1"};
  assert.strictEqual(isTitleChanged(current, same), false);
  assert.strictEqual(isTitleChanged(current, different), true);
})();

console.log("All titleUtils tests passed");
