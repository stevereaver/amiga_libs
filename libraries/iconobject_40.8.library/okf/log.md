---
type: Log
title: iconobject 40.8 work log
---

- SAS/C build: no RomTag in hunk0; Resident at DATA+0x16c,
  InitTable at DATA+0x15c, functab 11 longs at DATA+0x12c.
- Verbatim transcription byte-identical; fixup.py splices the
  4-group RELOC32 tails.
- Oracle identical (embedded-resident scan + byte InitStruct
  unused — datatab=0).
