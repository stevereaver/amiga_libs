---
file: log
---
# Work log

- 2026-10-15: muirexx 19.9 (12.02.97) — 2-hunk (CODE+BSS)
  non-AUTOINIT lib (Stefan Stuntz, MUI ARexx cmds). Raw .byte
  + catharsis fixup verbatim; BYTE-IDENTICAL first try.
  Oracle: RomTag @h0+0x56 flags=00 -> rt_init code @h0+0x374
  runs MakeLibrary(ftab=h0+0xe40, dsz=0x54) + AddLibrary;
  13 abs-long vectors incl. relocated-0 -24 ->CODE+0 stub;
  lazy dep open (dos/utility/intuition v36, muilowlevel v19)
  into 20B BSS on first Open; deferred expunge; RUNTIME-
  IDENTICAL, 72 invalids (all from -66 deref of fake args).
