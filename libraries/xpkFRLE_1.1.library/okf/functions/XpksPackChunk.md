---
type: Function
title: XpksPackChunk
description: FRLE encoder — repeat/literal runs with XOR-obfuscated headers.
lvo: -36
registers: a0 XpkSubParams *, a6 base -> d0 0 | -17
timestamp: 2026-10-10T22:45:00Z
---

# ``LONG XpksPackChunk(struct XpkSubParams *p)``

**LVO -36**

Reads `xsp_InBuf`/`InLen`/`OutBuf`/`OutBufLen`, writes the packed
stream and `xsp_OutLen`.  Returns 0 or -17 (XPKERR_EXPANSION) when
the output buffer overflows — there is no "output >= input" bail
like xpkRLEN's.

Segment logic (see [FRLEFormat](../algorithms/FRLEFormat.md)):

- 2+ equal bytes at a segment start -> repeat run, n <= 129,
  header `(n-2)^0x9f` + byte.
- otherwise gather a literal until a **3-run** is found (the
  literal ends before it) or ~128 bytes are budgeted; header
  `(len-1)^0x1f` + raw bytes.
- 2-equal-byte pairs inside a literal stay literal — asymmetry vs
  segment starts.
- emits even when a repeat gains nothing (a 2-run costs 2 bytes
  for 2 bytes).
- quirks: literal scanner reads past the input end (clamped at
  emit); budget permits ~130-byte literals that overflow the
  header; repeat emit checks 1 byte of headroom for a 2-byte
  write.  See [findings](../findings/index.md).
