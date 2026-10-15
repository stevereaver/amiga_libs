---
type: Findings
title: rexxidentify 1.16 quirks
---

# Findings / quirks

- Base-relative (DREL16) build: relocand fields are LONGWORDS
  storing hunk-relative offsets, not word fields — the listed
  offsets point at 32-bit slots (resident ptrs, InitTable,
  functab, datatable longs, abs.l store/load operands, jump
  table).  Groups: 32x h0->h0, 6x h0->h1 (BSS refs).
- DREL16 terminator is a word; an extra 0000 pad word follows
  before the longword-aligned HUNK_END.
- Hunk0 alloc size (0x369) exceeds body (0x365): the tail 4
  longwords are the library's variable cells — self-modifying
  data living past the code image inside the same hunk.
  rt_EndSkip = 0xda4 covers them.
- ID_RELEASE returns the literal string '16 1.16(12.11.2022)'
  (h0+0x3ee) — duplicated '16 ' prefix looks like a botched
  version/revision concatenation in the original source.
- Reserved vector -24 returns 0 (d0=0/rts stub), Open increments
  opencnt without range checks; Close can drive opencnt negative
  (observed 0xffff under oracle).
