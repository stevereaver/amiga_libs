---
type: Library
title: xpkMASH.library 2.0(020) "Mashiner 020+ V2.0"
description: >-
  Zdenek Kadelac XPK sublibrary (1 Oct 2013), 68020+ build.
  Same bit-stream family as MASH V1.16 but a completely
  different matcher: pass1 builds a per-position gap array
  from a 64K-entry rolling 16-bit pair-key head table,
  pass2 is a lazy matcher walking gap chains that writes
  unaligned 6-byte {pos.w, dist.w, len-2.w} records back
  over the head table, and a third pass emits the mixed
  flag-bit / literal-byte stream.  Verified byte-identical
  against the original under a Musashi oracle.
timestamp: 2026-10-28T00:00:00Z
---

# xpkMASH.library 2.0(020)

"Mashiner 020+ V2.0" — XPK sublibrary, -m68020 required:
the record format is unaligned 6-byte triples {pos.w,
dist.w, len-2.w} written at byte addresses (word stores
at odd offsets are 68020+ only).

## Binary facts

- 2096 bytes, single CODE hunk (1976 bytes), `HUNK_RELOC32` x17
- entry stub `moveq #0,d0; rts` at code+0 (also the -24/-48/-60
  vector targets via word offset -146/0xff6e)
- RomTag at code+4: RTF_AUTOINIT, rt_Version 2, NT_LIBRARY,
  pri 0, rt_EndSkip 0.  Standard Resident layout
  (rt_MatchTag at +2).
- InitTable at code+0x62: dataSize 38 (Library + seglist
  long), functab code+0x92 (`ffff` marker + word offsets
  relative to the marker), datatab code+0x72 (8x/9x/ax
  offset-opcode InitStruct encoding), initRoutine code+0xaa
- LibInit stores seglist at base+34, then refuses
  (`moveq#0,rts`) unless AttnFlags has AFB_68020 set
- reloc[0] patches code+0 — on a real load the entry stub's
  `moveq` operand is corrupted by the base add; reserved
  vectors jump to garbage.  The rebuild deliberately does
  not reproduce this bad relocation.
- idstring `$VER: xpkMASH V2.0 (1 Oct 2013) by Zdenek Kadelac`
  (rt_Version/lib_Version = 2, lib_Revision = 0)
- XpkInfo @ code+0x6d4: {1,2,2,0}, "Mashiner" / "Mashiner
  020+ V2.0" / "WindowSize: 32KB, 2 mixed streams",
  ID 'MASH', Flags 9, Max/DefPkInChunk 64KB, MinPkIn 0,
  msgs Mashing/UnMashing/Mashed/UnMashed, DefMode 100,
  one mode record {next 0, upto 100, flags 1,
  packmem 0x40010, unpackmem 0, pspeed 7, uspeed 120,
  ratio 473, chunk 0, " -->"}.

## Vectors (word offsets relative to functab marker @0x92)

| LVO | off | target | function |
|-----|------|--------|----------|
| -6  | 0x002e | 0x0c0 | LibOpen   |
| -12 | 0x003c | 0x0ce | LibClose  |
| -18 | 0x004e | 0x0e0 | LibExpunge |
| -24 | 0xff6e | 0x000 | entry stub (ret0) |
| -30 | 0x008c | 0x11e | XpksPackerInfo |
| -36 | 0x00ae | 0x140 | XpksPackChunk |
| -42 | 0x0094 | 0x126 | XpksPackFree (dangling ptr) |
| -48 | 0xff6e | 0x000 | entry stub |
| -54 | 0x0486 | 0x518 | XpksUnpackChunk |
| -60 | 0xff6e | 0x000 | entry stub |

## Contents

- [vectors](functions/vectors.md) — lifecycle + xpk entries
- [layout](structures/layout.md) — params, base, workmem
- [format](algorithms/format.md) — bit-stream grammar,
  tables, matcher passes
- [defects](findings/defects.md) — shipped defects, all
  reproduced
- [log](log.md) — reverse-engineering log
