---
file: vectors
---
# Vectors

14 LVOs (-6 .. -84), absolute functab@h1+0 ->h0:
+0x56/+0xea/+0x70/+0x10c/+0x29c/+0x914/+0xa20/+0xc18/+0x960/
+0x988/+0x288/+0x330/+0x364/+0x7e4.

initfn@h0+0x12a: exec -558 (NewList/CreateMsgPort-family) +
-444 (AddPort) wiring a private port at lib+0x26.
User vectors exercise uuid create/copy/compare/format paths
(-36 returns 0x80 handle-ish; -54..-72 echo the a0/a1 buffer ptrs;
-84 returns 0x10 = uuid size).
