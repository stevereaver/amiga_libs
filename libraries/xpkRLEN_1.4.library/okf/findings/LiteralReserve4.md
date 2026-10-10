---
type: Finding
title: Literal reserve of 4
description: The expansion check reserves 4 bytes for a 1-byte token.
timestamp: 2026-10-10T09:40:00Z
---

# Literal reserve of 4

The encoder's bound check is `if (out + 4 + pend > outlim) return
-17`. A literal flush actually writes `1 + pend` bytes (token +
data), and a repeat run writes 2 — so the check is conservative by
~3 bytes per iteration. Worst case it returns `XPKERR_EXPANSION` for
outputs that would just have fit; xpkmaster then stores the chunk
uncompressed — correct but occasionally suboptimal.
