---
type: Findings
title: Bootblock.library 3.1 quirks
---

# Findings / quirks

- 4-hunk layout with the functab + idstring living in hunk1
  CODE (not DATA) and the main implementation in hunk3 — the
  resident only carries a stub + Resident + InitTable.
- hunk0+0 is `moveq #-1; rts` — returns -1 as a segment entry.
- initfn only opens dos.library; expansion.library and
  trackdisk.device strings live in hunk3 for the bootblock
  device path.
- idstring ends with CRLF (0x0d 0x0a) — DOS-style line ending
  baked into the string.
