# tdisk.library 4.1 (26 February 1988)

`binary/tdisk_4.1.library` — 2536 bytes, single CODE hunk (0x958 body),
RELOC32 relocations (23 longs, descending offset order — original
toolchain convention).  Fuller Computer Systems' raw-MFM floppy library:
drives Amiga disk hardware directly via CIA-A/CIAB and the custom-chip
registers (DSKLEN/DSKPT/DSKBYT/ADKCON/DMACON/INTENA/INTREQ).

Reconstruction: `source/tdisk_lib.s` — pure 68000 assembly, byte-
identical output (md5 `208c8aec7bd8c33570eb58bbbbbecf94`).  `make` in
`source/` assembles with m68k-amigaos-gcc and post-processes the link
with `reorder_relocs.py` (GNU ld emits RELOC32 offsets ascending; the
original linker emitted them descending).

Byte-exactness notes: the original assembler did not shrink
`move.l #imm` to `moveq` and emitted explicit `An@(0)` displacement
forms where gas optimises to `(An)`.  Those sites are written as raw
`.short`/`.long` pairs in the source (commented with the mnemonic).

Init: opens `disk.resource` via `OpenResource`, walks unit numbers 3..0
(dbf), asks `GetUnitID` for each, AllocMems a 32-byte unit struct +
16 KiB track buffer per live unit, and InitStructs the unit from one of
two embedded templates (code+0x134 / code+0x182, selected on whether the
GetUnitID result is non-zero).  Unit pointers land at lib+0x2e..0x3d
(the loop leaves lib+0x42 unused — the array has a spare slot).

Verified: file byte-identical; `work/oracle.py` drives init, all
vectors, Select ready/deselect, deferred expunge, and the
GetUnitID-all-fail path — identical output on original and rebuild.

- [functions/vectors.md](functions/vectors.md) — LVO map and calling convention
- [structures/layout.md](structures/layout.md) — library data + RomTag/InitTable layout
- [findings/quirks.md](findings/quirks.md) — quirks and oddities
- [log.md](log.md) — work log
