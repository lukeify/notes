# WebExtensions

## Manifest v3

## declarativeNetRequest

Instead of procedurally blocking or modifying requests and responses, requires developers to implement a "rules" DSL on how requests should be blocked by the browser:
Consists of four properties, one of which is optional:

* `id`
* `priority` (optional). If left off, `priority`=1
* `condition`, an object containing predicate(s) the browser will evaluate.
* `action`, the response to take if the condition yields true, an object where the `type` property is either `block` or `modifyHeaders`.

### [`updateStaticRules`](https://developer.chrome.com/docs/extensions/reference/api/declarativeNetRequest#method-updateStaticRules)

Supposedly implemented in Chrome 111 (associated GitHub ticket), with [chromium tests here](https://chromium.googlesource.com/chromium/src/+/86cf9e194ae801b3bfde08c253a7a12dae6b0cb7/chrome/test/data/extensions/api_test/declarative_net_request/update_static_rules/background.js).
However, doesn't actually appear to work in the real-world—static rules that are disabled via this method call continue to be registered with the `declarativeNetRequest` API and continue work.
Programmatically though, the API seems to function correctly to the point where the unit tests implemented in Chromium obviously pass.

Not implemented in Safari ([WebKit ticket](https://bugs.webkit.org/show_bug.cgi?id=261039)) or Firefox.

### `updateEnabledRulesets`

A workaround is instead of updating rules, just have one rule per ruleset and use the actually functional (in Chrome) at least `updateEnabledRulesets`.
