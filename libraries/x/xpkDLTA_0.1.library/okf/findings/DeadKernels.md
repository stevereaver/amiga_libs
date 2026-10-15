---
type: Finding
title: DeadKernels
description: Unreachable word/long delta routines at the hunk tail.
---

# Dead kernels — hunk+0x2e0..0x31f

Four routines sit past the used code with no callers:

| off | routine |
|-----|---------|
| 0x2e0 | 16-bit delta encode (`lsrl #1,d2`; movew; subw/addw) |
| 0x2f2 | 16-bit delta decode (addw accumulate) |
| 0x300 | 32-bit delta encode (`lsrl #2,d2`) — uses `subw` on
  the low word but `addl` on the accumulator (mismatched
  widths, likely a latent bug) |
| 0x312 | 32-bit delta decode (addl accumulate) |

The byte codecs at 0x214/0x26e `bsr` only to the byte
kernels at 0x2c4/0x2d4.  The XpkMode description
"ByteMode" plus DefMode=100 hints at a planned
Byte/Word/Long mode selector that was never wired into
the functab.

Reconstructed as static functions in xpkDLTA.c for
completeness.
