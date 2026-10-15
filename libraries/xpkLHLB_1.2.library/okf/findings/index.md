---
type: Finding
title: xpkLHLB 1.2 findings
tags: [quirks]
timestamp: 2026-10-15T00:00:00Z
---

# xpkLHLB 1.2 findings

- **Self-contained**: despite XpkInfo.lname "preprocessor for
  lh.library", there is no lh.library name string and init calls
  no OpenLibrary — the codec is fully embedded (contrast
  xpkLHLB_1.1 which was a pure lh.library adapter with an
  absolute-longword functab).
- **Functab format changed vs 1.1**: 1.2 uses a word-offset table
  with a leading 0xffff marker (initfn +0x160); 1.1 used absolute
  longs.
- **Shared free stub**: -42 and -60 both target +0x274 —
  FreeMem(state)+FreeMem(ctx 28B); the same code frees whichever
  ctx xsp_Sub[0] points at.
- **Deferred expunge**: standard — sets bit3 of lib_Flags, Close
  to 0 completes it, returns seglist.
- **68020-only code**: uses 020 indexed/indirect addressing and
  must assemble with -m68020.
- **Post-increment field access**: pack reads xsp fields via
  `a3@+`, so later indexed reads are relative to xsp+8 — the
  "OutBufLen" bound is really xsp+0x0c and OutLen lands at
  xsp+0x10.
- **Streaming**: consecutive PackChunk calls on the same
  XpkSubParams reuse Sub[0]/Sub[1] state; oracle shows a second
  74-byte chunk packing successfully on the live ctx.
- Error contract: pack -> -17 (0xffffffef) on missing
  ctx/InBuf/InLen/scratch/table or packed>=OutBufLen; unpack ->
  -2 on failure path.
