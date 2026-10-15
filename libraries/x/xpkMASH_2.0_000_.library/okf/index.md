---
type: Library
title: xpkMASH.library 2.0(000) "Mashiner V2.0"
description: >-
  Zdenek Kadelac XPK sublibrary (1 Oct 2013), the 68000
  build.  Wire-format identical to the 020 sibling
  (verified byte-for-byte under the Musashi oracle): the
  only differences are codegen — no scaled-index
  addressing (lea+addal pairs instead), no AFB_68020
  LibInit gate, LongName "Mashiner V2.0".  Same two-pass
  gap-chain matcher and mixed flag/literal bit stream.
timestamp: 2026-10-28T00:00:00Z
---

# xpkMASH.library 2.0(000)

"Mashiner V2.0" — XPK sublibrary, plain 68000.  Shares all
codec logic with `xpkMASH_2.0_020_.library` — see that
bundle for the full algorithm docs; this bundle notes the
deltas.

## Binary facts

- 2100 bytes, single CODE hunk (1980 bytes — 4 more than the
  020 build), `HUNK_RELOC32` x17
- RomTag at code+4: RTF_AUTOINIT, rt_Version 2, NT_LIBRARY,
  rt_EndSkip 0
- InitTable at code+0x62: dataSize 38, functab code+0x92
  (ffff marker + word offsets), datatab code+0x72 —
  byte-identical header/datablock to the 020 build
- LibInit at code+0xaa: `moveal d0,a1; movel a0,a1@(34);
  rts` — stores seglist, no CPU check (020 sibling gates
  on AFB_68020)
- reloc[0] still patches code+0 — entry-stub corruption at
  load is present in this build too
- XpkInfo @ code+0x6de: identical to the 020 build except
  LongName = "Mashiner V2.0"

## Vectors (offsets relative to functab marker @0x92)

| LVO | off | target | function |
|-----|------|--------|----------|
| -6  | 0x0020 | 0x0b2 | LibOpen   |
| -12 | 0x002e | 0x0c0 | LibClose  |
| -18 | 0x0040 | 0x0d2 | LibExpunge |
| -24 | 0xff6e | 0x000 | entry stub (ret0) |
| -30 | 0x007e | 0x110 | XpksPackerInfo |
| -36 | 0x00a0 | 0x132 | XpksPackChunk |
| -42 | 0x0086 | 0x118 | XpksPackFree (dangling ptr) |
| -48 | 0xff6e | 0x000 | entry stub |
| -54 | 0x048c | 0x51e | XpksUnpackChunk |
| -60 | 0xff6e | 0x000 | entry stub |

Targets sit ~0xe lower than the 020 build throughout —
exactly the size of the removed CPU-gate block.  All
vector offsets are byte-different but the routines are
the same modulo codegen (`lea`+`addal` vs scaled index).

## Contents

- [vectors](functions/vectors.md) — lifecycle + xpk entries
- [layout](structures/layout.md) — params, base, workmem
- [format](algorithms/format.md) — bit-stream grammar,
  tables, matcher passes
- [defects](findings/defects.md) — shipped defects, all
  reproduced
- [log](log.md) — reverse-engineering log
