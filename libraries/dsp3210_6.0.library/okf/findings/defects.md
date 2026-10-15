---
type: Findings
title: dsp3210 6.0 quirks
---

# Findings / quirks

- Same skeleton as the 5.0 sibling: single CODE hunk, COLDSTART
  resident at +0x04, word-offset functab (`ffff` marker … `ffff`),
  only 5 RELOC32 entries — all inside the resident struct
  (matchtag/endskip/name/id/init). Every other internal reference
  is pc-relative, so the DSP routines and the d32 data ride
  unreloc'd inside the code hunk.
- Module-entry stub now returns **-1** (`moveq #-1,d0/rts` at
  h0+0x00) instead of 0 — a cosmetic flag flip, since the real
  init path is rt_Init@+0x9c; oracle entry result unchanged.
- Version bookkeeping is consistent again: resident rt_Version=6,
  initfn writes lib_Version=6 (`movew #6` at h0+0xe2), and the
  idstr `6.0 (20.8.2021)` properly *postdates* 5.0's
  `(4.8.2021)` — the date-stagnation quirk noted for 5.0 is
  resolved.
- **Error codes unchanged** from 5.0 — the odd-negative set
  (-3/-5/-7/-9/-11/-21/-23/-31) is byte-for-byte identical
  (verified by immediate-operand diff); no renumbering this time.
- **-66 guarded free reworked** (+6 bytes at h0+0xba2): the old
  fall-through that returned the adjusted block pointer (or
  FreeMem's d0) is now an explicit status protocol —
  `clrl sp@-` … `notl sp@` … `movel sp@+,d0` yields -1 on
  successful free, 0 on NULL/cookie-mismatch. Oracle: -66 ->
  0x0 (5.0 returned 0x4ff00). Alignment requirement relaxed
  from `andib #3` (long) to `btst #0` (even) — even-aligned
  blocks that 5.0 rejected are now accepted.
- **New -90 vector** (h0+0xbd4, +0x22 bytes): walks a
  NULL-terminated longword pointer array, calls -66 on each
  entry and `clrl a0@`-clears the slot only when the free
  reports success. Notably the library already invoked
  `a6@(-90)` internally (h0+0xa0e) on the *secondary* base
  (a5@(38)) — 6.0 exposes the matching service on itself.
- All code between the functab and h0+0xba0 shifted +2 (functab
  growth); code after h0+0xbd4 shifted +0x2a. Pc-relative
  displacements adjusted accordingly (+0x28/-0x28 deltas only).
- The DSP register-name table lost its 2 tail pad bytes (h0+0xfa4
  now begins code right after the `0000` terminator; 5.0 padded
  at h0+0xf7a). Net body growth vs 5.0: +40B = +2 functab, +6
  reworked -66, +0x22 new -90, -2 pad.
- `cmpiw #36,a6@(20)` still guards an exec -642 call — the code
  conditionally uses a v36+ exec feature (unchanged).
