---
type: Library
title: xpkCBR0.library V1.0 "Cmp Byte Run 0 Packer"
description: >-
  XPK compression sublibrary implementing the simplest
  possible byte-oriented RLE (literal runs <=128, repeat
  runs 2..128).  AUTOINIT word-offset functab; 0xaa-byte
  base embeds runtime-initialised XpkInfo/XpkMode
  descriptors; entry stub returns -1.  V1.0 carries a
  lib_Flags bit-numbering quirk (LIBF_SUMMING used where
  LIBF_DELEXP belongs) fixed in the V1.1 rebuild.
timestamp: 2026-10-28T00:00:00Z
---

# xpkCBR0.library V1.0

XPK sublibrary ("Cmp Byte Run 0") by Bilbo of Hypenosis
(23-Aug-1992) — trivial RLE codec: header <0x80 emits a
literal run of h+1 bytes (1..128), header >=0x80 emits a
repeat run of 257-h bytes (2..128).  No stream
terminator; the decoder stops at input exhaustion.

Same sublibrary family as xpkFRLE/xpkRLEN.  Descriptors
are written into the library base by LibInit at runtime
(dataSize 0xaa: XpkInfo@+0x28, XpkMode@+0x80), and the
three unused sublib slots point at bare `rts` stubs.

## Binary facts

- 1300 bytes, single CODE hunk
- RomTag: RTF_AUTOINIT, RT_VERSION 1, NT_LIBRARY
- entry stub: `moveq #-1,d0 ; rts` (returns -1)
- functab: AUTOINIT word-offset table, 10 vectors
- dataSize 0xaa; seglist stored at base+0x24
- `$VER:` string uses 0xa0 (NBSP) as separator
- sha256: `2572b3228725a9bd...`

## Vectors

| LVO | Function | Notes |
|-----|----------|-------|
| -6  | LibOpen | opencnt++, clears flag bit0 (see quirks) |
| -12 | LibClose | opencnt--, deferred expunge on flag bit0 |
| -18 | LibExpunge | Remove+FreeMem or sets flag bit0 |
| -24 | LibNull | `moveq #0,d0; rts` (ExtFunc slot) |
| -30 | XpksPackerInfo | returns base+0x28 |
| -36 | XpksPackChunk | RLE encoder |
| -42 | LibRts | bare rts (PackFree) |
| -48 | LibRts | bare rts (PackReset; also jsr'ed as nop) |
| -54 | XpksUnpackChunk | RLE decoder |
| -60 | LibRts | bare rts (UnpackFree) |

## External calls

exec.library: Remove (-252), FreeMem (-210) — expunge only.
The codec and LibInit touch no LVOs.

## Reconstruction

- `source/xpkCBR0.c` — framework + codec in C
- `source/xpkCBR0_lib.s` — RomTag/AUTOINIT skeleton + strings
- `source/functab*.s`, `source/genfunctab.py` — two-pass
  word-offset vector table
- `source/Makefile` — m68k-amigaos-gcc two-pass build
- Host test: 39644 codec round-trips, 0 failures
  (plus 951+1391 round-trips on random data; -17 expansion
  rejects on incompressible input are shipped semantics)
