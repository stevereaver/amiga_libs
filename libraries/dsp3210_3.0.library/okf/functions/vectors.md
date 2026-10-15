---
type: Functions
title: dsp3210 3.0 vector map
---

# Vector map (functab h0+0x138, 11 absolute longs)

-6 0x0c8 Open · -12 0x0d8 Close · -18 0x0f2 Expunge ·
-24 0x134 stub · -30 0x168 · -36 0x1f6 · -42 0x200 ·
-48 0x964 · -54 0xadc · -60 0xb34 · -66 0xb08

Under the oracle: -30 on a valid d32 blob returns 4
(section length); -36 walks relocations via exec -198;
bad-magic inputs return 0xffffffff; -54/-66 return
0x4ff00 (base-0x100 mask off an arg pointer).
