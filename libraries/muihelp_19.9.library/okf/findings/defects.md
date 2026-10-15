---
file: defects
---
# Findings

- NOT AUTOINIT: rt_Flags=0x00, so rt_Init->h0+0xec is a
  routine (not an InitTable). It hand-fills the Library node
  and defers dep opens to first Open. (Siblings catharsis/
  powerpacker were AUTOINIT; the InitData decoder path is
  unused here.)
- hunk 2 is type 0x400003ea — DATA with memory flag
  0x40000000 (chip request), declared 6 longs, body present
  but entirely zero: a flagged-BSS-in-disguise. Relocatable
  reference from h0+0xa58.
- Vector -24 (reserved) is a relocated ZERO: functab slot
  h0+0xb20 stores 0 and lands on CODE+0 (the `moveq #0,d0;
  rts` reserved fn) after RELOC32->h0.
- IdString inconsistency: RomTag rt_IdString ->h0+0x1a
  ("muihelp.library 19.9 (12.02.97) ©1992-1997 Stefan
  Stuntz\r\n" — text *after* the "$VER: " cookie), but the
  init routine stores lib_IdString ->h0+0x14 (the full
  "$VER:"-prefixed string). Both valid; they differ by 6B.
- Five words at h0+0xe4..0xed (0,0x1b37,0,0x1b34,0) between
  the dep-name strings and the init routine — build/version
  tags, never referenced by code.
- muigfx.library is opened with the library's own version
  (19) while all other deps are v36 — i.e. requires muigfx
  >= 19 specifically.
- RELOC32 appears only on h0 (3 groups); h1/h2 have none.
- Rebuild: `make` BYTE-IDENTICAL; oracle diff orig vs
  rebuild clean, invalid-accesses 0.
2026-10-15
