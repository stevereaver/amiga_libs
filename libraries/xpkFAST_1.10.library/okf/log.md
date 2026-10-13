# xpkFAST 1.10 — RE session log

## Phase 1 — inventory

- 2136-byte single-hunk library; hunk typed HUNK_DATA (linker
  quirk — code lives in a data-typed hunk, MEMF_PUBLIC).
- RomTag: AUTOINIT, rt_Init -> code+0x1e, name/idstr nearby.
- InitTable `{0x22, functab 0x2e, datatab 0x5a, initfunc 0x7e}`;
  10 LONG functab entries, all relocated.

## Phase 2 — disassembly

- HUNK parsed manually; 30-entry RELOC32 list decoded.
- Mapped all 10 vectors; identified the same xpkFAST core as
  1.06 (context-free call convention — args straight from xsp).
- Instruction-level diff vs the 1.06 disassembly: packer and
  decoder bodies identical modulo encoding sugar; differences
  confined to lifecycle/dispatch/metadata (see index.md).

## Phase 3 — reconstruction

- Reused the verified `xpkfast_1.06.library` C pack/decoder
  bodies verbatim; rewrote lifecycle + wrapper + skeleton.
- `xpkfast_lib.s` reproduces the original layout byte-for-byte:
  literal `dc.l 4` MatchTag (deliberately NOT in the reloc
  list), dead cells + `dc.l -1` + segslot so initfunc lands at
  +0x7e and the segslot store's operand sits at reloc 0x84.
- C core: `dataSize 0x22` bare library; `moveal 4:w,a6` for
  exec calls; PackFree called via `a6@(-42)`; mode `<= 80`.

## Phase 4 — verification (Musashi 68000 oracle)

- Lifecycle: init fields, open/close/expunge, DELEXP path —
  verified.
- Pack: 37 randomized cases (fresh machine per case, after
  discovering two coexisting Machine instances confuse
  machine68k's global trap table and produce phantom crashes —
  harness artifact, not code): packed streams byte-identical,
  workmem sizes/alloc-free log identical, -17 collisions
  identical, mode 79/80/81 boundary correct (80 -> speedy on
  both).
- Unpack: round-trips verified; decoder consumes streams from
  both packers identically.
- Descriptor: all scalar fields + strings identical (pointer
  fields differ only by each build's own base offset).

## Known harness hazard

The codec's OOB-read defects make results heap-content
dependent when input slack regions differ between runs; the
regression pre-fills the input slack with 0xAA for determinism.
Multiple live Machine objects in one process also break
machine68k trap dispatch — one machine per pack, or separate
processes.
