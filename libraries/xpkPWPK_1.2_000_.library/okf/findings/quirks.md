---
type: Finding
title: xpkPWPK 1.2(000) quirks
---

# Quirks

- **Margin bail via saved SP**: the encoder stores SP at ctx+50
  and longjmps (`moveal 50(a4),sp`) when the bit-writer reaches
  dst+srclen-8 — pack of incompressible data returns -17
  (XPKS_Error) rather than falling back to a store mode.
- **Lazy ctx**: params+0x34 is populated on first pack with a
  0x31046-byte (mode-dependent `0x30046+(1<<e3)*8`) AllocMem
  block, flags=0 (not MEMF_CLEAR — tables explicitly zeroed).
  Vector -42 frees it via the size cell at handle-4.  Unpack
  stores the *params pointer itself* there as a sentinel
  (`MOVE.L A0,52(A5)`), so -42 after unpack would FreeMem the
  caller's params — caller-beware API defect.
- **xsp+0x20 is a userdata pointer, not a flag**: non-NULL ->
  content is run through the rolling checksum into the trailer
  and the packed payload is XOR-encrypted.  Verified round-trip
  under oracle (match=1, corrupt trailer -> -32).
- **Mode selection is odd**: mode idx = (params+0x1c - 1)/20 & 15,
  so raw xsp mode field 0 selects mode0; values index into the
  5-entry mode chain by upto-threshold.
- **(A0) predecrement read on ctx handle** in -42 relies on the
  size cell stored by the ctx constructor — fragile but stable.
