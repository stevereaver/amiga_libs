---
type: Log
title: Reconstruction log
---

# Log — xpkFRLE_1.2_000_.library

- Scanned: 984-byte hunk; compact V1.2 layout (entry stub +
  RomTag + strings + InitTable before the code, descriptors
  and string table after it, "EVE" tag at the tail).
- Phase 1: functab decoded as word offsets from _functab
  (hunk+0x92); null slots are -0x92 -> the hunk+0 stub.
  RomTag EndSkip=0, AUTOINIT, ver 1; InitStruct rev 2.
- Phase 2: codec decoded -- same stream format as V1.1
  (verified the decoder formulas are identical), new impl:
  sliding 3-byte-window scanner, computed-goto unrolled
  stores.  Found: OOB scans, inflated tail-literal capacity
  check -> near-certain -17, missing OutLen write,
  OutBufLen never read, >128-byte literal corruption,
  entry stub reused as null vector/return trampoline.
- Phase 3: C reconstruction; genfunctab emits the negative
  offsets to _start.  Host tests: 30k random round-trips --
  all pass; expansion rejects reproduce; the >128-byte
  literal-tail corruption reproduces byte-identically
  (0x9f header), inlen==0 -> -17.
- Phase 4: this OKF bundle; defects filed in Plane.

## 2026-10-15
- Byte-verbatim asm reconstruction (`source/xpkFRLE_h0.s`),
  same convention as xpkFRLE_1.1: single .text hunk, word-
  offset functab (negative offsets -0x92 -> hunk+0 stub),
  datatab emitted raw, islands/strings verbatim.  `cmp`
  byte-identical (md5 0f04897f92c3b8ebbdde6f666991cd90).
- RELOC32 tail is ASCENDING (13 sites) unlike V1.1's
  descending -- fixup.py just normalizes/verifies.
- machine68k oracle (work/oracle.py): identical logs orig vs
  rebuild across init, open x2, entry stub, null vectors,
  XpkInfo/XpkMode fields, round-trips incl. literal >127
  segmentation, 129-max repeats, len-2 tail edge, 130-distinct
  -17 (inflated capacity check), zero-length, OutBuf+InLen
  overflow -17, deferred + real expunge.
- vs V1.1 diffs confirmed while transcribing: entry stub
  returns 0 (was -1) and is reused as null vector + branch
  trampoline (word branches); RT_ENDSKIP=0; $VER: cookie;
  rev 2; Open uses bclr (was andi); functab AFTER datatab;
  pack reads pb[0..2] via moveml a0@ (a0 kept for the OutLen
  store), bound = OutBuf+InLen; encoder is a sliding
  3-byte-window scan with dbne run counter; tail literal uses
  eorb d0,d3 (V1.1: eorb d2,d5); unpack writes NO OutLen and
  decodes via jmp pc@(2,d1:w) into 32-store blocks;
  noncanonical AND.B/SUB.B immediates gone (and.w d0,d1 now).

- Phase 4 (2026-10-15): verbatim asm `xpkFRLE_h0.s` -> BYTE-IDENTICAL
  (md5 0f04897f92c3b8ebbdde6f666991cd90).  machine68k oracle adapted
  from the V1.1 harness; logs identical.  Confirmed live: pack bounds
  by OutBuf+InLen (pure-literal input always returns -17), unpack
  never stores xsp_OutLen, ret0 stub at hunk+0 doubles as the
  return-0 trampoline.
