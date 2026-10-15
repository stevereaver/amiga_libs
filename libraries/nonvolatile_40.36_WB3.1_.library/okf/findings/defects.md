---
type: Findings
title: nonvolatile 40.36 quirks
---

# Findings / quirks

- Dual RomTags: the second one is a post-dos deinstall hook
  (v0, ty=0) — it clears the cache and removes itself.
- open x2 then close x2 underflows opencnt to 0xffff; the
  deferred-expunge tail still runs (remove + closelib x2 +
  freemem with stale args).
- Word-offset functab rather than absolute longs.
