---
file: log
---
# Work log

- 2026-10-15: dgsmus 2.1 — 3-hunk Optonica music lib
  (CODE+DATA+DATA|CHIP).  Raw .byte bodies for all three
  hunks (.text/.data/.datachip); linker emits them in the
  needed order, fixup.py splices the original header,
  hunk tags (incl. 0x400003ea) and the hunk-0 RELOC32 tail
  (31/39/1 slots) verbatim: BYTE-IDENTICAL.  machine68k
  oracle: RomTag -> InitTable (word-format InitStruct),
  21-vector jump table, six fake sublib bases, open x2 /
  dispatcher cmd lists / all vectors / close x2 / expunge;
  logs diff clean orig vs rebuild.
