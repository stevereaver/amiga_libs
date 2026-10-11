# Work log — explode_7.0.library

## Reverse engineering

- IRA V2.09 disasm of the 1668-byte code hunk (config in
  `work/explode_7.0.cnf`); one pass sufficed — same family as the
  previously reconstructed 5.6.29.
- Functab at hunk+0xb6 (LONG form, 6 vectors + -1): -6 Open,
  -12 Close, -18/-24 shared ret-0 stub, -30 Explode trampoline,
  -36 mark-for-expunge.
- LibInit patches dos `LoadSeg` (-150) **and** `NewLoadSeg` (-768)
  with two in-hunk `jsr $0` stubs; NewLoadSeg stub `bra`s over the
  LoadSeg stub into the shared signature check.  Old vectors stored
  in the stub operands and base+46/+50.
- Signature check accepts `"explode.library\0"` or the
  `"ed explode.libra"` variant at hunk+40 behind the `48E7FFFF`
  decrunch-stub head.
- Decoder = same LZ+Huffman coroutine as 5.6.29 (identical tables)
  with hunk-walk and ring-read inlined at every site, movem.l
  32-byte burst copies, and unconditional CacheClearU (the
  advertised 68040/60 fix).

## Reconstruction

- `explode_lib.s`: header + strings + functab + datatab hand-laid to
  the original offsets; stubs, signature check, -30 trampoline,
  decoder and tables transcribed verbatim.
- `explode.c`: lifecycle in C (LibInit/Open/Close/expunge/ExpMark).
- Build: m68k-amigaos-gcc -m68000 -O2 -ffixed-a5, single hunk link.

## Verification

- Verbatim block (hunk 0x1f2-0x682, 1168 B): **0 byte diffs** vs the
  original after one fix — a plain `bhi` had to be `bhis` (gas treats
  unsuffixed branches as .w).
- Header 0x0-0xfd byte-identical modulo relocated pointers
  (endskip/functab/initfunc).
- C codegen reviewed against disasm: LibInit ordering (open, forbid,
  2x SetFunction+operand patch, CacheClearU, permit), expunge
  restore order, Open/Close/Mark flag ops — all faithful.

## Inconsistencies recorded

- lib_Version 6 / rev 0 vs "7.0" idstring and rt_Version 7.
- init returns success on OpenLibrary failure (no wedge installed).
- unconditional vector restore on expunge (no slot check).
- incomplete second signature ("ed explode.libra" — tail unchecked).
- filed in Plane (see card referenced in README).
