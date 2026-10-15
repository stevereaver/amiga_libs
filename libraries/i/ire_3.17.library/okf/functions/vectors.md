---
file: vectors
---
# Vectors (9 abs-long @h0+0x20c)

-6 Open +0xcc | -12 Close +0x16c | -18 Expunge +0xf0 |
-24 stub +0xc | -30 +0xd44 | -36 +0x1184 | -42 +0xfb0 |
-48 +0x748 | -54 +0x804.

initfn @h0+0x10 opens dos.library v36 (returns 0 if
missing). -30 does exec -684 (FindTask-ish) then walks
invalid addrs (138 deterministic under oracle).
