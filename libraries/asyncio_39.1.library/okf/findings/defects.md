---
type: Findings
title: asyncio.library 39.1 quirks
---

# Findings / quirks

- Resident sits mid-hunk at +0x8c, after the functab and the
  InitTable at +0x4c — rt_Init points back at the earlier
  InitTable.  hunk0+0 is a `moveq #0; rts` stub that doubles as
  the -24 reserved vector (functab entry 0x0000 relocates to
  hunk base).
- The file ships a header declaring 2 hunks where hunk1 is a
  body-less HUNK_BSS of 20 bytes; code operands relocate into it.
- InitData is empty (datatab = 0); the InitTable itself performs
  only the functab/datasize wiring, and initfn writes all private
  fields.
- machine68k logs byte-read probes stepping through the high
  0xfffffexx range during several calls — deterministic on both
  original and rebuild (speculative read patterns in the async
  request path when ports are stubbed).
