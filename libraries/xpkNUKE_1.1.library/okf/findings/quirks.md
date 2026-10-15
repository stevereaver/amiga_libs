---
type: Finding
title: xpkNUKE 1.1 quirks
timestamp: 2026-10-15T00:00:00Z
---

# Quirks of the shipped binary (all reproduced verbatim)

1. **IdString is "Version 1.0"** — not the library name/version.
   The real `$VER: NUKE 1.1 (Nov  2 1992)` lives in the data hunk
   (+0x14) and is copied into the private lib area where nothing
   reads it as a resident version tag.
2. **PackFree (-42) leaves xsp_Sub[0] dangling.**  It frees the
   84-byte ctx, the 0x20000 and 0x10000 tables, but never writes 0
   back to xsp+0x34.  A following pack with the stale Sub[0] would
   reuse freed memory.  (Unlike xpkNUKE 1.9 which clears it.)
3. **XpksUnpackChunk always returns 0** and never writes
   xsp_OutLen — the caller must preload xsp+0x10 with the expected
   unpacked size; corrupt input is undetected.  -60 is a pure
   no-op stub (unpack keeps no state), and -48 returns 0.
4. **InLen/OutBufLen are truncated to 16 bits** (stored via movew
   at ctx+0x20/+0x22).  Inputs > 64KiB wrap.
5. **Silent corruption above MaxPkInChunk.**  XpkInfo advertises
   max chunk 0x7530 (30000); a 40000-byte run of identical bytes
   packs "successfully" (rc 0, outlen 8) but does not round-trip
   on the original — callers must honour the chunk limit.
6. **OutLen is written before validation.**  A failing pack
   leaves 0xffffffff (core overflow) or the oversized length in
   xsp+0x10; rc -17 follows either outlen>inlen or outlen<0.
7. **Unusual AUTOINIT boot path.**  dataTab is NULL — InitStruct is
   skipped entirely.  InitFn itself memcpy's the 284-byte data
   block into lib+0x3a and patches 8 block-relative pointers via a
   table stored *after* the block image (data+0x11c count,
   +0x120 offsets).  The copied region even contains the InitTable
   bytes and the $VER string, now dead weight in the lib.
8. **Delayed-slot stream writer.**  Each bit stream's first flush
   writes its (still zero) accumulator to a 4-byte scratch area at
   ctx+80..83 — exactly the last four bytes of the 84-byte ctx
   allocation, before the slot pointer is redirected into the
   output stream.  Sized to the byte.
9. **Expunge hooks a noop.**  Both the init tail call (jsr 0xaf0)
   and the pre-expunge call (jsr 0xaec) hit bare `rts` stubs —
   placeholders for the later xpk versions' real init/cleanup.
10. **objdump misreads the header.**  The pad word at +0x1e glues
    onto `linkw a5,#-20` (init entry) so linear disassembly shifts
    everything by two bytes; the reconstruction marks it .byte.
