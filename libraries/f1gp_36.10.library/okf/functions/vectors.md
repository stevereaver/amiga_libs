---
file: vectors
---
# Vectors

11 LVOs (-6 .. -66), absolute functab@h0+0x3b8:
-6 open +0x46c, -12 close +0xca, -18 expunge +0xd0 (returns
seglist; Remove+FreeMem+FreeSignal), -24 reserved +0xd8,
-30 +0xb8a (msgport path: -564 FindPort/-570 reply ops +
-120/-126 signal dances), -36 +0x6bc (AllocMem 20B msg),
-42 +0x6e2 (port remove + mem free), -48 +0x100 (returns
0xffffe6ce - odd constant), -54 +0x67e (alloc20),
-60 +0x6a4 (port remove + free), -66 +0x7f4.

initfn is null — libInit is a no-op; all setup happens in the
COLDSTART init itself.
