---
type: Findings
title: dsp3210 7.1 quirks
---

# Findings / quirks

- Same skeleton as the 7.0 sibling: single CODE hunk, COLDSTART
  resident at +0x04, word-offset functab (`ffff` marker … `ffff`),
  only 5 RELOC32 entries — all inside the resident struct
  (matchtag/endskip/name/id/init). Every other internal reference
  is pc-relative.
- Version bookkeeping: resident rt_Version=7 (unchanged — a
  revision bump, not a version bump), initfn writes
  lib_Version=7 (`movew #7` at h0+0xe2) and now
  **lib_Revision=1** (`movew #1,a0@(22)` at h0+0xe8 — 7.0 used
  `clrw` there). idstr `7.1 (12.12.2021)` postdates 7.0's
  `(29.8.2021)` by ~15 weeks.
- **DSPCOMPAT probe argument change** (the only code-logic
  delta): in the lazy dos helper at h0+0xf32, the call to
  `a6@(-906)` on the secondary (dos.library) base now passes
  `d4=0` via `moveq #0,d4` (h0+0xf4e) instead of `d4=0x100` via
  `movel #0x100,d4`. The probe signature there is
  `d1="DSPCOMPAT" ptr, d2=16-byte scratch on stack, d3=16,
  d4=flags`. Whatever bit 0x100 meant for the lookup is no
  longer requested; oracle trace shows d4=0 vs 256 (and 2 vs
  258 after the `orib #2,d4` DSPCOMPAT-success path in the
  -48/-78 shared body). 4 bytes shorter → the code window
  0xf50-0x1059 sits 2 bytes earlier than in 7.0.
- **New `0000` terminator on the register-name records**
  (h0+0x105a). 7.0's `dmac` record ended with its string NUL +
  one pad byte and code followed at 0x105c; 7.1 adds an explicit
  terminator word so anything walking the record list (as
  opposed to the 12-entry offset table, which already had a
  `0000` terminator at 0x1000/0x1002) stops cleanly. +2B.
- Net code size delta vs 7.0: +2 (initfn) −4 (probe) +2
  (terminator) = 0 — file stays exactly 4648B and the body still
  ends on `rts` at h0+0x11de. All other diffs are displacement
  bookkeeping: 20 pc-relative/branch operand bytes changed where
  instruction and target sit in different shift windows —
  +4: 0xfbb, 0xfdd (insn in −2 window, target in +2);
  +2: 0xa9 (functab lea) and 0x107b/0x1089/0x1099/0x10ab/
  0x1167/0x1175/0x1185/0x118d/0x11a5 (insn in the realigned
  0-window, target in +2);
  −2: 0xef, 0x921, 0xf41 (insn in +2, target before 0xe8);
  −4: 0x199, 0x233, 0x399, 0xcf7, 0xcfb (insn in +2, target
  in −2).
- The word-offset functab is **byte-identical** to 7.0's —
  every vector offset is relative to the table base and all 15
  targets moved +2 together with it.
- Container model (`0x00fc2011` cookie, +4 pointer-array table,
  +8 embedded MinList, nodes key@+8/table@+12) is completely
  unchanged; so are the block cookie `0x32102011`, the odd
  error-code set (-1/-3/-5/-11/-21/-23/-31 tails at 0x942-0x968
  plus the -7/-5/-9 slots pushed inline in the -48/-78 body), the
  `cmpiw #36,a6@(20)` v36-guard and the `tstb a6@(43)` probe
  flag logic.
- rt_Init is still at h0+0x9c because the idstr's extra byte
  (+1 char for `12.12` vs `29.8`, +1 pad) was absorbed by two
  pad bytes after `dos.library` (which moved 0x56→0x58 while
  `DSPCOMPAT` stayed at 0x64).
