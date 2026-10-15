---
file: defects
---
# Findings

- RomTag rt_flags = 0x00: NOT autoinit. rt_Init points at real
  code (h0+0x374) which calls exec MakeLibrary(ftab=h0+0xe40,
  dSize=0x54) itself, fills the Library node manually, then
  AddLibrary()s itself [exec -396]. Init failure path FreeMem()s
  the lib and returns 0.
- Vector -24 is a relocated ZERO: functab slot @h0+0xe4c holds 0
  covered by a RELOC32->h0 entry, resolving to CODE+0 — the
  `moveq #0,d0; rts` reserved stub. (Same pattern as catharsis'
  -30 slot.)
- Everything lives in one CODE hunk: name/idstring, RomTag,
  builtin command tables (0x70..0x1f0) and all strings sit
  inside the 0x1340B code hunk; the only other hunk is a 20B
  BSS of five library-base pointers reached via abs-long
  operands (`lea 0.l,a4` + RELOC32->h1).
- rt_idstring -> h0+0x1a points *past* the "$VER: " prefix into
  "muirexx.library 19.9 (12.02.97) ...", while init stores the
  full "$VER:..." string (h0+0x14) at lib+0x18. Both correct.
- Seglist stored at lib+0x22 (two bytes below the standard
  lib_SegList @+0x24); OpenCount at +0x20 is standard.
- lib+0x26 list head is NewList'ed at init but then used as the
  Obtain/ReleaseSemaphore target — the 14B MinList doubles as
  the SignalSemaphore list header.
- Deferred expunge via bit3 of lib+0xe: Open clears it,
  Expunge sets it when OpenCnt!=0, Close tail-calls Expunge on
  the last close.
- Oracle note: vector -66 called with NULL-ish args still walks
  a5@+4 (uninitialised RexxSysBase slot in our fake arg block)
  producing 72 invalid reads before returning — deterministic,
  identical orig vs rebuilt.
- Rebuild: BYTE-IDENTICAL (make), oracle diff clean.
2026-10-15
