# xpkTDCS 1.2 — reconstruction log

## Session notes

- Parsed RomTag (packed, code+0x08, AUTOINIT), InitTable
  (dsize 0x3c), word-offset functab (10 vectors), byte-serial
  InitStruct datatab (a0/90/80 commands — word-aligned reads
  misparse it), LibInit (seglist @+0x26, AFB_68020 gate).
- Disassembled full packer: exec-pool hash table
  (CreatePool/AllocPooled/FreePooled/DeletePool), growable
  position arrays, newest-first candidate walk with
  {best-1,best}+{1,2} word prechecks, +3-start long compares.
- Decoder decoded: signed16 distances via `moveq #-1` + `movew`
  (upper word survives → sign extension), 16-item flag longs,
  flag-0 fast path = 16 literal bytes.
- Reconstruction: C codec + asm lifecycle skeleton +
  two-pass functab generator (same build as the 1.5 sibling).

## Bugs fixed during oracle bring-up

- datatab emitted as `.long 0x800a0000` — reserialized as
  byte-stream commands (cmd,off,data).
- `remaining` never decremented on match emits (llen only set
  on literals) → -17 overrun on compressible input.
- maxlen clamp was read as an uninitialized slot — actually
  aliases `remaining`'s low word (sp@148+2).
- realloc copy loop: two `movel`s per 4-byte decrement →
  2*used longs, overruns — now reproduced.
- decoder flag-0 fast path copied 64 bytes; original copies 16.
- cmpml a0@+,a2@+ post-increments past the failing long —
  decoder compare fixed; encoder tail refinement backs up to
  the failing long.
- the "dead" lazy-adopt path is live: sp@74/78/82 are
  word-written through their low-word aliases sp@76/80/84;
  gate is `lenL - d6 <= pending → reject`.  Implemented the
  full lazy chain (literal emit + insert per adopt).
- insert 259-trim reads `blk[used-259]` (a position), copies
  hidden 516-long shift — corrected from an earlier
  never-fires reading.

## Oracle (work/oracle.py, machine68k M68020)

Emulates MakeLibrary + InitStruct + initfn, exec stubs for
AllocMem/FreeMem/Remove/CreatePool/DeletePool/AllocPooled/
FreePooled (bump allocator + freed-block reuse; POOLBASE reset
per pack to keep the arena finite).

Results: all 11 test streams byte-identical to the original
(empty, one, lit16, lit40, z64, z300, ab_rep, abc, txt, allb,
rep4k); every produced stream round-trips through the
reconstructed decoder; -17/-7 paths match.  `txt` required the
lazy-adopt chain to match exactly (63 bytes).

Residual: one extra AllocPooled(16) on the original's lit16/allb
-17 paths — emulator `bcc` does not take equality, so the
original's `bhis` overrun check behaves as `>`; the C keeps `>=`
(true to the binary on real hardware).

Plane: AMIGALIBS-111.

- Phase 5 (2026-10-15): verbatim asm `xpkTDCS_h0.s` via the
  objdump-transcription pipeline + fixup.py reloc splice ->
  BYTE-IDENTICAL (md5 a42a86a4ed1d3d29a31aaf66ed104e4b).
  Existing machine68k oracle re-run orig-vs-rebuild: all test
  streams byte-identical (RUNTIME-IDENTICAL), incl. the
  pool/hash encoder paths and the -17 overflow cases.
