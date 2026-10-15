---
type: Finding
title: Quirks in xpkDLTA 0.3(000)
---

# Quirks

- **rt_EndSkip = 0, unrelocated.**  The RomTag EndSkip cell holds
  literal `0` and carries no RELOC32 entry — the Init resident scan
  range ends wherever the loader leaves it.  Same pattern as
  xpkNONE 1.5.
- **RomTag version = 0.**  `rt_Version` is 0 and the Exec library
  Version/Revision come only from InitStruct (0/3).
- **UnpackChunk never writes xsp_OutLen.**  Verified under machine68k:
  the field keeps its caller-supplied value.  PackChunk does write it.
- **No bounds checks.**  Unlike 0.2 there is no `InLen > OutBufLen`
  (-10) or `InLen > 64K` (-11) test; the codecs always return 0.
- **InLen == 0 runs away.**  The loop is `subq.l #1,d1 / bne` with no
  pre-check; InLen 0 wraps to ~4G iterations, streaming memory until
  it crashes.  Do not hand it empty chunks.
- **Null vectors are backward functab offsets** (`0xff6c`) to the
  `moveq #0,d0/rts` stub at code+0 — the same entry stub doubles as
  reserved-vector target (-24/-42/-48/-60).
- **Mixed branch widths**: Close uses word branches back to code+0
  (`6600 ff38`, `6700 ff2e`, `6000 ff1e`) while the in-function tests
  use byte branches — reproduced verbatim.
