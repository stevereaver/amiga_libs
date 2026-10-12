---
type: Log
title: xpkMASH 2.0(000) reverse-engineering log
---

# Reverse-engineering log — xpkMASH_2.0_000_.library

Source: `binary/xpkMASH_2.0(000).library`, 2100 bytes,
one CODE hunk (1980), 17 RELOC32 entries.
Plane: AMIGALIBS-98.  Done immediately after the 020
sibling (AMIGALIBS-97, commit ff78acd).

## Approach — sibling diff, not a fresh RE

Ran the completed 020 oracle harness directly against this
binary: same InitTable layout (dsize 38, functab @0x92,
datatab @0x72 — byte-identical header block), vectors at
the same relative positions ~0xe lower.

Disassembly diff vs the 020 build shows the deltas are
pure codegen:
- 68000 can't encode scaled-index EA (`%a2@(d3:w:2)` etc) —
  the 000 build uses `lea a3@(d1:l)` + `addal` pairs and
  plain word-index modes throughout
- no AFB_68020 gate in LibInit (8-byte routine vs 22)
- decoder tail region restructured for word-safe addressing
- LongName "Mashiner V2.0" (not "Mashiner 020+ V2.0")

Record stores `movew a0,a3@+ / movel d2,a3@+` at even
addresses (6-byte stride from even base) — legal on 68000;
the "020" was never about alignment.

## Oracle verification

Loaded the original under the Musashi harness: all 10
vectors resolve, LibInit runs, pack/unpack work.
Packed streams for all 40 regression inputs are
byte-identical to the 020 build's (modulo the shared
uninitialized final flag-slot byte).  Same defect
signature: unbounded cmpmb reads, the batch-mode dirty
workbuf cases produce garbage/-17/wild writes just like
the original.

## Reconstruction

`source/xpkMASH.c` — identical codec file to the 020
build (the C is portable; records via a UWORD cursor are
even-aligned so already 68000-safe), compiled -m68000.
`source/xpkMASH_lib.s` — 020 skeleton minus the AttnFlags
gate; "Mashiner V2.0" longname.  Functab regenerated.

Build: 5380 bytes.  The built .library was loaded and
exercised through its vectors under the same oracle —
all streams identical to the original's (the t07/t20
batch-mode divergences are the documented dirty-workbuf
UB, present in the original as 1MB garbage output +
wild write to 0xfffffffe; the rebuild hits the same
defect class and fails cleanly).
