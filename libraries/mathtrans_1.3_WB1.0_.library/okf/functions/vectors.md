---
type: Functions
title: mathtrans 1.3 vector map
---

# Vector map (functab h0+0x7a, 18 absolute longs, 2-aligned)

-6 h0+0x108 Open · -12 h0+0x144 Close · -18 h0+0xc6 Expunge ·
-24 h0+0x05c (initfn slot) ·
-30 h1+0x7a · -36 h1+0x84 · -42 h1+0x8e · -48 h1+0x98 ·
-54 h1+0xa2 · -60 h1+0xbe · -66 h1+0xc8 · -72 h1+0xd2 ·
-78 h1+0xdc · -84 h1+0xe6 · -90 h1+0xf0 · -96 h1+0xfa ·
-102 h1+0x10e · -108 h1+0x118

The 14 ->h1 entries are the transcendental functions
(MC68343 firmware entry points).  Under the stub oracle
they return raw FFP-format constants (e.g. 0x80000041 =
1.0 in fast-float).
