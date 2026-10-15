# script.library 0.4 — work log

- Parsed hunk file: CODE(2292) + DATA(24) + CODE(88) + 3 RELOC32
  groups; AUTOINIT RomTag at h0+4, InitTable in DATA at +4,
  functab+strings in hunk2.
- Full disasm of hunk0 (808 lines).  Identified vbcc-style compiled C:
  stack args for internals, register args a0/a1/a2 for public vectors,
  `a4 = a6+48` data base.
- Mapped all 12 vectors; identified rexxsyslib.library dependency and
  its private-vector calls; identified pool-based named-entry store.
- Pure-asm transcription in three objects + linker script; two `@(0)`
  displacement elisions and two reloc-immediates fixed; fixup.py
  restores descending grouped RELOC32 order.
- Result: byte-identical (MD5 d9289bf0a34ecb9f9c42b88a275900fd).
- work/oracle.py (machine68k): identical traces for init, lifecycle,
  ctx ops, entry store/find, callback set/get, -30/-36 rexx round-trip
  (status-40 path incl. msg+252 stash/restore), deferred expunge.
- Initially misread the list walk as skipping the last element; the
  oracle proved all nodes are checked — the real quirk is the iter-1
  strcmp on lh_TailPred bytes (see findings).
