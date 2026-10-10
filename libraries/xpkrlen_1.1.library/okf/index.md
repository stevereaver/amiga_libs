---
type: Library
title: xpkRLEN.library V1.0/1.1 "Run Length"
description: >-
  xpkRLEN XPK sublibrary (Nov 2 1992) -- a byte-run RLE with
  a signed count byte per token: positive=literal run,
  negative=byte replicate, zero=terminator.  Two-hunk SAS/C
  build: INITFUNCTION copies a 256-byte template (InitTable +
  strings + XpkInfo/XpkMode) into base+58 and relocates four
  descriptor pointer fields.  Codec has no output bound on
  the run emit and the decoder has no bound at all.
timestamp: 2026-10-28T00:00:00Z
---

# xpkRLEN.library V1.0/1.1

"Run Length" XPK sublibrary — the simplest codec in the set:
`<signed count>` per token, `>0`=copy literals, `<0`=replicate
the next byte, `0`=terminator.  Runs are found by a
3-in-a-row lookahead and capped at 127, literals flush at
127 or on a run boundary.

## Binary facts

- 1384 bytes, TWO hunks (CODE + DATA), SAS/C build
- sha256: `62c8e5a968b50ce256892b1c102d0ae2c0adbedf4be4f22796fa84e48e28cb5e`
- RomTag (CODE hunk): RTF_AUTOINIT, ver 1, NT_LIBRARY,
  RT_INIT -> InitTable in the DATA hunk
- entry stub `moveq #0,d0; rts` (also the null vector)
- InitTable: dataSize 0x13a, FUNCTABLE = LONG-address table
  (10 vectors + ffff ffff), dataTable=0, init=INITFUNCTION
- INITFUNCTION: fills base fields, copies 256B template
  SECSTRT_1 -> base+58, adds base+58 to 4 descriptor ptrs
  (reloc list {0xe2,0xb6,0xb2,0xae} at data+0x100)
- XpkInfo lives at base+224 (inside the copied block)

## Vectors

| LVO | Function | Notes |
|-----|----------|-------|
| -6  | LibOpen | standard |
| -12 | LibClose | DELEXP bit handled |
| -18 | LibExpunge | Remove+FreeMem |
| -24 | _start | null (ExtFunc) |
| -30 | XpksPackerInfo | -> base+224 XpkInfo |
| -36 | XpksPackChunk | RLE packer |
| -42 | XpksPackFree | stub (d0-untouched) |
| -48 | XpksPackReset | stub (returns 0) |
| -54 | XpksUnpackChunk | RLE decoder |
| -60 | XpksUnpackFree | stub (d0-untouched) |

## External calls

exec.library: Remove (-252), FreeMem (-210) — expunge only.
No AllocMem (workmem-free codec, packmem advertised as 0).

## Reconstruction

- `source/xpkrlen.c` — framework + codec (C)
- `source/xpkrlen_lib.s` — RomTag, INITFUNCTION (copy+fixup),
  FUNCTABLE, DATA-hunk template + reloc list
- long-address FUNCTABLE -- no genfunctab pass needed
- Host test: 19701 round-trips, 0 errors, 299 `-17` rejects
