---
file: vectors
---
# Vectors (22 word-offset @+0xca)

-6 Open +0x1e8 | -12 Close +0x216 | -18 Expunge +0x24c |
-24 +0x302 | -30 +0x1038 | -36 +0xe16 | -42 +0x119e |
-48 +0x141a | -54 +0xff0 | -60 +0xf64 | -66 +0x1250 |
-72 +0xe98 | -78 +0x13e4 | -84 +0xfb8 | -90 +0xe6e |
-96 +0x1230 | -102 +0xef2 | -108 +0xf48 | -114 +0x320 |
-120 +0x12c2 | -126 +0x324 | -132 +0x1046.

initfn @+0x11c calls exec -408 then FreeMem(0x106) on
its seglist cell. Vectors hit exec -138 repeatedly
(a semaphore/notify op) — quickdos patches DOS vectors.
