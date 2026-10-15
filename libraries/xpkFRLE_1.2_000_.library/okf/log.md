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

- Phase 4 (2026-10-15): verbatim asm `xpkFRLE_h0.s` -> BYTE-IDENTICAL
  (md5 0f04897f92c3b8ebbdde6f666991cd90).  machine68k oracle adapted
  from the V1.1 harness; logs identical.  Confirmed live: pack bounds
  by OutBuf+InLen (pure-literal input always returns -17), unpack
  never stores xsp_OutLen, ret0 stub at hunk+0 doubles as the
  return-0 trampoline.
