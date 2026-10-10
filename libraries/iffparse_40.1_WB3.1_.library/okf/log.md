---
type: Log
title: Work log
timestamp: 2026-10-10T18:00:00Z
---

# Work log

## 2026-10-10 — build, verification, documentation

- Cross-compiled `source/` with m68k-amigaos-gcc 16.2: valid HUNK
  output (.text 0x1f94, .data 0x8c, .bss 4).
- Fixed base-pointer scheme: single file-scope `IFFBase` pointer set
  by LibInit (NDK `*_BASE_NAME` macros expand inside header helper
  functions where no local exists).
- Found and fixed a real vector-table bug: `dc.w func-functab` across
  objects emits RELRELOC16 (target-minus-position), which corrupts
  every entry.  Solved with a two-pass link (`genfunctab.py` writes
  literal `.word` offsets from nm output).  All 45 slots verified
  against symbols.
- Corrected earlier mis-reads: hook+8 is `h_Entry` (standard), not
  `h_Data`; the "legacy 52-byte IOClipReq" is just the standard NDK
  struct — custom `ClipIOReq40`/`ClipHandle40` removed.
- libbase gained the missing pad word at +0x22; field offsets now
  byte-identical (SysBase@0x24, DOS@0x28, Util@0x2c, Seg@0x30,
  vectors@0x34..0x43).
- Alloc flags corrected from disassembly: MEMF_CLEAR for the IFFHandle,
  root ContextNode and LocalContextItem; flags 0 for ContextNodes,
  collection items, write buffers, clipboard handle.
- LibInit fail path now matches: close both libs, Alert 0x38007
  (dos) / 0x3800c (utility), return NULL.
- OKF bundle seeded (functions, structures, findings).

## 2026-10-10 (earlier) — full disassembly

- Parsed hunk header, RomTag (RTF_AUTOINIT), InitTable
  (dataSize 0x44, word-offset functable, 45 entries).
- Mapped all 45 LVO slots to code; decoded every function.
- Identified 7 built-in hook objects in .data (stride 0x14, h_Entry
  at +8): prop handler, stop handler, collection handler,
  stop-on-exit handler, collection purge, DOS stream, clip stream.
- LibInit: OpenLibrary(dos,37), OpenLibrary(utility,37), caches the
  four utility jump-table slot addresses (+0x34..0x43).
- Determined private layouts: IFFHandle(40), ContextNode(40),
  LocalContextItem(24+data), ClipboardHandle(120 = standard NDK).
- Wrote initial C reconstruction + RomTag/functab asm + Makefile.
