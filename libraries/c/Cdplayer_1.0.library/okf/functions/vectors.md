---
file: vectors
---
# Vectors

16 LVOs (-6 .. -96), functab@h2+0 -> h0 targets
+0xd0/+0x1fe/+0x268/+0 (dead slot ->h0+0)/+0x332/+0x36a/+0x3b2/
+0x3f2/+0x428/+0x5f2/+0x684/+0x714/+0x896/+0x99e/+0xb0a/+0xbe6.

Command entries exec PutMsg (-456) to a device port and AllocMem
(-684) for track/frame buffers — CD command packet dispatch.
open returns context ptrs (0x300060/0x3001c4 style — a4-relative
global state at lib+0x22).
