---
file: vectors
---
# Vectors

14 LVOs (-6 .. -84), word-offset functab@h0+0x170:
-6 open +0x100, -12 close +0x110, -18 expunge +0x12a,
-24 reserved +0x16c, -30 DSPCalcLen +0x190,
-36 DSPRelocate +0x21e, -42 +0x228, -48 +0x98c,
-54 +0xb52, -60 +0xbbe, -66 +0xb92, -72 +0xbfc,
-78 +0x998, -84 +0xdf0.

Oracle: -30 validates d32 magic 0x0166 -> returns seg count/4;
-36 allocs and returns -3 on the minimal blob; several vectors
return -1 stubs; -48/-78 probe exec -552.
