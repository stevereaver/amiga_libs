---
type: Function
title: DSPCalcLen
description: Computes the destination buffer size needed to relocate a d32 blob.
lvo: -30
timestamp: 2026-10-10T20:10:00Z
---

# Signature

```c
LONG DSPCalcLen(const UBYTE *blob, ULONG bound);
/*                a0                 d0       */
```

The `d0` bound is not in the current FD (`DSPCalcLen(blob)(A0)`) —
the binary's symtab-bounds check uses it, so this early API took the
blob size/end in d0. See [ApiDrift](../findings/ApiDrift.md).

# Semantics

1. `blob->magic != 0x0166` → -1
2. `symtabOff + symCount*18 > bound` → -1 (MULU, low word of count)
3. `nsec == 0` → -1
4. For each 40-byte section record: flags must equal 0x20, 0x40 or
   0x80 exactly, else -2; accumulate `align4(size)`.

Returns the total aligned size, -1 (bad blob) or -2 (unknown section
type). See [d32 blob format](../structures/D32Blob.md).
