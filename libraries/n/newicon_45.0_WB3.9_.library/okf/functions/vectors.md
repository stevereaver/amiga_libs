---
type: Functions
title: newicon 45.0 vector map
---

# Vector map (functab h1+0x00, 13 absolute longs -> h0)

-6 0x080 Open · -12 0x13a Close · -18 0x0e8 Expunge ·
-24 h0+6 stub · -30 0x43c · -36 0x508 · -42 0x74a ·
-48 0x768 · -54 0x9dc · -60 0xa7e · -66 0xa82 ·
-72 0xb7e · -78 0xb9a

Under stubs: open returns 0 (missing real icon.library);
-30 returns 1, -54 calls exec -684 with a 0x51000 buffer,
-78 returns 0x8000902d (tag-list-ish value).
