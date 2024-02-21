# WebExtensions

Caveats and idiosyncrasies of WebExtension APIs and their varying levels of browser support.

## Manifest v3

### `declarativeNetRequest`

Instead of procedurally blocking or modifying requests and responses, requires developers to implement a "rules" DSL on how requests should be blocked by the browser.
Consists of four properties, one of which is optional:

-   `id`
-   `priority` (optional). If not provided, `priority` will equal `1`.
-   `condition`, an object containing predicate(s) the browser will evaluate.
-   `action`, the response to take if the condition yields true, an object where the `type` property is either `block` or `modifyHeaders`.

#### [`declarativeNetRequest.updateStaticRules`](https://developer.chrome.com/docs/extensions/reference/api/declarativeNetRequest#method-updateStaticRules)

Supposedly implemented in Chrome 111 (associated GitHub ticket), with [chromium tests here](https://chromium.googlesource.com/chromium/src/+/86cf9e194ae801b3bfde08c253a7a12dae6b0cb7/chrome/test/data/extensions/api_test/declarative_net_request/update_static_rules/background.js).
However, doesn't actually appear to work in the real-world—static rules that are disabled via this method call continue to be registered with the `declarativeNetRequest` API and continue work.
Programmatically though, the API seems to function correctly to the point where the unit tests implemented in Chromium obviously pass.

Not implemented in Safari ([WebKit ticket](https://bugs.webkit.org/show_bug.cgi?id=261039)) or Firefox.

#### `declarativeNetRequest.updateEnabledRulesets`

A workaround is instead of updating rules, just have one rule per ruleset and use the actually functional (in Chrome) at least `updateEnabledRulesets`.

#### Regular expression limitations

DNR matches conform to one of three types. One of these is `regexFilter`, but there is no syntax described in the WebExtensions specification for what functionality is available to regexes, as outlined in this [GitHub issue](https://github.com/w3c/webextensions/issues/344):
Some notes on this with respect to Chrome's support.

> In Chrome, regexpFilter is basically the syntax of the underlying RE2 library plus the additional implementation-dependent constraint that the memory usage of an individual regex may not exceed 2kb

However, Safari `regexFilter` syntax is much more limited, and [described here](https://developer.apple.com/documentation/safariservices/creating_a_content_blocker#3030754).
One important missing piece of functionality is OR expressions, i.e. `(gallery|poll)` to match the strings `gallery` or `poll` respectively.
Practically, this means this rule must be split into two separate rules.

`regexFilter` is not supported in Firefox yet.

### `storage`

Defines an API where data can be persisted for a web extension.
There are a few `StorageArea`'s for manifest v3 web extensions, one of which is [`storage.local`](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/storage/local).
One of the methods of each `StorageArea` is `get`, which accepts a `keys` argument (either a single string, or an array of strings) defining the keys to retrieve persisted data for.
Providing `null` is defined in the spec as returning the entire storage contents.

Unfortunately, Safari (both macOS and iOS) [does not support this functionality](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/storage/StorageArea/get#browser_compatibility), so you must manually store all keys and provide that as an array to retrieve all contents.
