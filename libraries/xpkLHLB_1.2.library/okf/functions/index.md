---
type: Function
title: xpkLHLB 1.2 vectors
tags: [lvo, functab]
timestamp: 2026-10-15T00:00:00Z
---

# xpkLHLB 1.2 vector map

Word-offset function table @CODE+0x2e, leading `0xffff` marker,
10 entries, `0xffff` terminator. Targets below are CODE+ offsets.

| LVO | target | function |
|-----|--------|----------|
| -6  | 0x16c | Open — opencnt++ (no LH deps) |
| -12 | 0x17a | Close — opencnt--; if DELEXP set and cnt==0 -> expunge |
| -18 | 0x188 | Expunge — Remove+FreeMem; defers via lib_Flags when open |
| -24 | 0x1be | reserved — bare rts |
| -30 | 0x1c2 | XpksPackerInfo — returns &XpkInfo (CODE+0x108) |
| -36 | 0x1ca | XpksPackChunk — see below |
| -42 | 0x274 | pack state free — FreeMem ctx(28)+table(40000), scratch |
| -48 | 0x1be | reserved — bare rts |
| -54 | 0x236 | XpksUnpackChunk — see below |
| -60 | 0x274 | unpack state free (shared free stub) |

## XpksPackChunk (a0 = XpkSubParams)

- Lazily allocs via xsp_Sub[0]/@+0x34: 28B context +
  40000B `MEMF_CLEAR|MEMF_PUBLIC` hash table; and a 36864B
  scratch at xsp_Sub[1]/@+0x38 (plain MEMF).
- ctx layout: +0 InBuf, +4 InLen, +8 scratch(=Sub[1]), +12 0x8000
  chunk size, +20 table size (40000).
- Validation (-17/`0xffffffef`) when ctx, InBuf, InLen, scratch
  or table missing — or when packed size >= xsp_OutBufLen.
- Success: CopyMem(scratch -> xsp_OutBuf, len); len ->
  xsp+0x10 (OutLen); returns 0.
- Chained chunks reuse the same ctx/table (streaming state).

## XpksUnpackChunk (a0 = XpkSubParams)

- Lazily allocs 4500B state + 28B ctx via xsp_Sub[0].
- ctx = {InBuf, InLen, OutBuf, OutBufLen} copied verbatim.
- Result byte count written to xsp+0x10 (OutLen); d0 = 0 on
  success, -2 (`seq`/`andb #-14` path) on failure.
