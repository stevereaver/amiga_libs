---
type: Functions
title: utilities 1.2 vector map
---

# Vector map (functab h1+0x308, 26 absolute longs -> h0)

-6 0x762 · -12 0x780 · -18 0x7aa · -24 h0+0 stub ·
-30 0x1d0 · -36 0x200 · -42 0x242 · -48 0x2de · -54 0x288 ·
-60 0x2fa · -66 0x380 · -72 0x3c2 · -78 0x40e · -84 0x050 ·
-90 0x07e · -96 0x0ac · -102 0x0de · -108 0x46e · -114 0x172 ·
-120 0x4d4 · -126 0x506 · -132 0x56e · -138 0x5ac ·
-144 0x606 · -150 0x62e · -156 0x688

Observed under stubs: -60 returns the AllocVec'd copy buffer
(0x51000), -66 returns it again, -90..-132 return small ints
(string-length/count helpers), -144/-156 return 0x323800.
