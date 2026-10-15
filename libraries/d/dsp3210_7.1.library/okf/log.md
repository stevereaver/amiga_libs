---
type: Log
title: dsp3210 7.1 work log
---

# Work log

- Single-hunk COLDSTART dsp3210 7.1 (4648B; hunk0 CODE 0x478
  longs = 4576B — same file size as 7.0). Reused the verified
  dsp3210_7.0.library pipeline: `work/gen_source.py` with only
  BIN path and the functab DATA span changed
  (0x170-0x190 → 0x172-0x192; head span 0x0-0x9c identical —
  the longer idstr was absorbed by pad bytes and code still
  starts at 0x9c); `source/Makefile` + `source/fixup.py`
  adapted to the 7.1 path.
- `make` -> gas assembles the verbatim .s, GNU ld emits the
  single hunk, fixup.py verifies the hunk body matches and
  splices the original RELOC32 tail (5 entries, descending:
  0x1a 0x16 0x12 0xa 0x6 — the resident pointer fields).
  Result: `cmp` BYTE-IDENTICAL
  (md5 cf2425cd321c067edf6f7eb2e325b8b3).
- `work/oracle.py` (machine68k, extended from 7.0's): exec
  -552 now returns a stubbed dos.library base so the
  DSPCOMPAT probe actually reaches `dos -906` (revealing the
  d4=0 vs 0x100 delta); exec -198 bump-allocates; RemHead /
  Remove / AddTail / FreeMem emulate real list ops; LIB is
  linked into a dummy list so Expunge's Remove can't zero the
  SysBase pointer (a pure-stub 7.0-style oracle never noticed
  this); `call()` rewrites mem[4] defensively. libInit reads
  back lib_Version=7 / lib_Revision=1 and the idstring.
  All 15 vectors + synthetic d32 blob + container fixtures
  (-60 table/node lookups, -66 keyed free, -90 drain,
  -54 block-free and lib2-dispatch, -36 into a container
  destination). orig.log == rebuild.log, diff clean,
  0 invalid-memory events.
- Alignment-aware diff (difflib) against 7.0: 3870 raw byte
  diffs collapse to a handful of real changes once the shift
  windows are accounted for:
  - idstr `7.0 (29.8.2021)` -> `7.1 (12.12.2021)` (+1B,
    pads reshuffled; `dos.library` 0x56->0x58, realigns at 0x64);
  - initfn `clrw a0@(22)` -> `movew #1,a0@(22)` —
    lib_Revision 0->1, +2B (code 0xec-0xf4d at 7.0+2);
  - DSPCOMPAT probe `movel #0x100,d4` -> `moveq #0,d4` —
    -4B (code 0xf50-0x1059 at 7.0-2);
  - `0000` terminator added after the `dmac` record at
    0x105a — +2B, code realigns to 7.0 offsets at 0x105c.
  Everything else is pc-relative displacement bookkeeping;
  the functab bytes are unchanged.
