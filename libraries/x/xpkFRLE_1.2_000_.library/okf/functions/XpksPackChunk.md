---
type: Function
title: XpksPackChunk
description: FRLE encoder.
---

# XpksPackChunk — LVO -36

`LONG XpksPackChunk(struct XpkSubParams *a0)` —
XOR-obfuscated ByteRun encoder.  Registers a1-a3 loaded with
`moveml a0@` (InBuf/InLen/OutBuf only -- xsp_OutBufLen is
never read).  Output bound = OutBuf + InLen.

- segment start: pair of equal bytes -> repeat run (2..128),
  `(n-2)^0x9f` + byte; 1-byte headroom check, writes 2
- literal: sliding 3-byte window scan until a run of three
  equals (literal ends before it) or ~127 scanned;
  `(len-1)^0x1f` + raw bytes; strict `<` capacity check
- returns 0; -17 (XPKERR_EXPANSION) on overflow
- InLen==0: OOB-scan then -17 (reconstruction returns -17
  deterministically without the reads)

See findings/Quirks.md for the OOB scans, the inflated
tail-literal check, and the >128-byte literal corruption.
