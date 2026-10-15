---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-15
- Byte-exact asm reconstruction (`source/cachemap_h0.s`).
  RELOC32 decodes as [count][hunk-index][offsets] groups: one
  group, hunk 0, offsets 6/a/12/16/1a/22/2a (RomTag + InitTable
  pointer fields only) — GNU ld reproduces it verbatim.  Confirmed
  strings are butt-packed with no alignment: gfx name at 0x360,
  libname at *odd* 0x371, idstr ends exactly at hunk end 0x39c.
  Oracle (work/oracle.py) emulates exec Forbid/Permit/AllocMem/
  FreeMem/AddTail/Remove/OpenLibrary + gfx InitBitMap with a
  programmable AllocMem fail flag; drives init, open/close, the
  -24 stub, CreateMap ok/misaligned/alloc-fail, AllocMapPlanes
  unwind, LockMap NULL-plane lock-leak, FillMapPlanes bit-per-
  plane fill + NULL skip, ScaleBits expand/decimate/long+word
  tails, plane-leak expunge and seglist-returning teardown.
  orig.log == rebuilt.log byte-for-byte.

## 2026-10-10
- Parsed RomTag/InitTable from the binary (word-offset functab,
  11 entries incl. negative -24 back to module entry).  Decoded all
  vectors: CacheMap = node allocator with embedded BitMap; -30 calls
  InitBitMap via graphics.library opened at init; -72 is a
  Bresenham bit-stream replicator.  Wrote C reconstruction with
  two-pass functab; `make` produces a valid library.  Populated okf/.
