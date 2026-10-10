---
type: Finding
title: Entry stub reuse
description: The hunk entry returns 0 and is reused as the reserved-vector target.
timestamp: 2026-10-10T09:20:00Z
---

# Entry stub reuse

The 4-byte hunk entry at .text+0x00 (`moveq #0,d0; rts`) serves three
roles at once:

1. the executable entry for non-resident loaders (returns 0 = failure);
2. the `RT_ENDSKIP` target — the resident scanner stops at offset 0,
   so the entire rest of the hunk is tag-covered;
3. the function-table target for the reserved vector (-24) and the
   unimplemented sublib slots (-42/-48/-60): those entries encode
   offset 0xff6e = -0x92, i.e. table base + offset = .text+0x00.

There is no separate LibNull stub anywhere in the hunk.
