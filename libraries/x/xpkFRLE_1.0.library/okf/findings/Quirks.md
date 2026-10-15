---
type: Finding
title: Format quirks
description: Cosmetic oddities of the shipped module.
---

# Format quirks

- **$VER cookie outside the idstring.**  The bytes
  `"$VER: "` sit at hunk+0x2e but RT_IDSTRING points at +0x34,
  `"xpkFRLE.library 1.0 (31-Jan-93)\r\n"` — the reported
  idstring omits the cookie marker.  (Later FRLE builds dropped
  the $VER text entirely.)
- **Revision 0.**  InitStruct sets lib_Revision = 0 although
  the version text says "1.0".
- **Entry stub returns -1.**  Hunk+0 is `moveq #-1,d0; rts`,
  before the RomTag — also reached by nothing else (all null
  functab slots point at a separate `moveq #0,d0; rts` stub).
- **Decoder writes OutLen** — the 1.2 rebuild lost this, so a
  1.2-unpack leaves xsp_OutLen stale.
