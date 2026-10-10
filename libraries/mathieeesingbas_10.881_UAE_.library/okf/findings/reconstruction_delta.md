---
type: Finding
title: Reconstruction deltas
description: Differences between the rebuilt library and the shipped binary.
---

# Reconstruction deltas

- Shipped `.text` hunk: 0x1c8 bytes; rebuilt hunk is larger
  (GCC 68000 codegen is more verbose than the original compiler: extra
  register saves, `movea.l 4.w,a6` reloads, duplicated code tails).
- Function order inside the hunk differs; the vector table maps LVOs
  correctly and all FPU instruction sequences are byte-identical to the
  shipped sequences (verified via objdump of both binaries).
- Original code shares tails: e.g. `IEEESPCmp`/`IEEESPTst` share the
  -1/0/+1 epilogues, and `IEEESPPow` branches into the reserved
  moveq#0/rts vector. The reconstruction duplicates equivalent tails.
- Strings/InitStruct bytes/RomTag fields are identical.
