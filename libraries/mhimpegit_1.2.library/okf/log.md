# mhimpegit.library 1.2 — RE log

- Started as "next smallest pending" after mhimpegit_4.0.library
  (AMIGALIBS-102) — same author/product, two-hunk layout instead of
  three (no BSS; globals live in DATA +0x92/+0x96/+0x9a/+0x114).
- Decoded structure by hand: packed `struct Resident` at data+0x3c
  (flags=0, not AUTOINIT), rt_Init → code+4 which self-creates via
  exec MakeLibrary(data+0x56 functab, dsize 42) + AddLibrary.
  14 vectors -6..-84 identical LVO map to 4.0.
- Semantic deltas vs 4.0 (all verified in disasm):
  - prelude opened with version 5 (4.0 used 4); extra gate:
    fail iff ver==5 && rev<2.
  - obj shrinks to 16B {tag0,tag1,count@+8,list@+12} (4.0 had
    18B {tag0,tag1,list@+8,count@+12}); obj AllocVec flags 0x10000.
  - create taglist value 99 for 0x8000003f (4.0 used 100).
  - pl@-60 now takes literal d1=0x1008,d2=22050 (4.0 left d1/d2 stale).
  - Drain sends literal 128 (4.0 OR'd 0x80 into stale d0).
  - Query is a clean boolean (4.0's sloppy obj|!flag removed).
  - Dispatch op1 no longer calls prelude (4.0 sent {0x3a,min}).
  - Fail paths in Create leak prelude (4.0 ran teardown);
    Destroy never frees the 12B list block.
  - rt_IdString points at a NUL pad — empty reported idstring.
- Reconstruction: C (`source/mhimpegit.c`) + asm stubs/data
  (`source/mhimpegit_lib.s`) + Makefile, mirroring the shipped
  2-hunk layout (data section reproduces all 280 bytes including
  pad bytes, the packed RomTag and both tag templates).
- Oracle (machine68k, M68020): emulated exec jump-table model
  (MakeLibrary builds `jmp` slots at lib-6..-84), prelude/dos stubs,
  taglist content capture.
  - LibInit sequence identical: openlib(dos,0) → makelib(14 vec,
    dsize 42) → addlibrary; lib header byte-identical (ln_Type 9,
    name, flags 6, neg 0x54/pos 0x2a, ver 1 rev 2, idstr→+0x12,
    seglist, execbase).
  - 65-entry exercise script: Open/Close/Expunge, Classify sweep
    (incl. string codes + fall-through), Create, Append (flag on/off),
    Query, Iterate, Pop-to-empty, Dispatch ops 0-8 × vals {50,150},
    Drain, Destroy — identical return values, identical call logs,
    identical taglist payloads.
  - Diff bugs found+fixed during verification: `l[34/4]` index
    truncation (wrote +32 not +34), missing pad byte after
    "dos.library", obj AllocVec flags 0x10000 vs 0x10001,
    Classify unknown-code result is 0 via mid-instruction `moveq`.
- Byte-verbatim reconstruction done: `source/mhimpegit_h0.s`
  (whole module in one file: `.text` hunk0 + `.data` hunk1) +
  `source/fixup.py` + reworked `source/Makefile` (default target =
  verbatim build + cmp; `make cmodel` keeps the C model).
  - Assembled clean with -m68000 (binary really is plain 68000 --
    the "020" muls/divs are runtime 16-bit ops; the only gas
    canonicalization mismatch was `lea a4@(0),a0`, which gas shrinks
    to `lea a4@,a0` -- forced via `.short 0x41ec,0x0000`).
  - Mid-instruction `cmpiw #0x7000/0x7001,d0` tricks reproduced as
    `.short 0x0c40` + labelled `moveq`; both PC-indexed jump tables
    (Dispatch @0x4b0, memcpy tail @0x55c) kept as .short word lists.
  - Reloc tails: shipped file stores hunk0's 14 code->data relocs
    descending and hunk1's 15 code + 4 self relocs descending;
    GNU ld emits identical sets ascending -- fixup.py verifies the
    (hunk,offset) multisets then splices the reference tails.
  - `cmp`: BYTE-IDENTICAL, md5 8456ebb8b380fdb053bd5ed966530ac0.
  - Oracle rerun on the rebuild: identical LibInit trace, identical
    42-byte lib header, 65-entry exercise script 0 diffs.
