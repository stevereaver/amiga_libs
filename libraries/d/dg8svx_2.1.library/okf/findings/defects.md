---
file: defects
---
# Findings

- **ln_Type never set (real defect):** InitData command
  `a0 0c` writes byte 9 at lib+0x0c instead of +8
  (ln_Type). The following long write of ln_Name at +0x0a
  immediately overwrites +0x0c, so ln_Type remains 0 —
  the library node is not tagged NT_LIBRARY. Harmless on
  OS versions that don't type-check nodes, hence shipped.
- **Dead compare in -30:** tag 0x70000 handler does
  `moveq #2,d0; cmpiw #0x7001,d0; move.l d0,sp@(76)` —
  comparing a constant just loaded; the cmp result is
  discarded, mode is always 2. Likely a source bug (meant
  to test the tag operand).
- **SysBase via DATA hunk:** all `movea.l $4`/`move.l a6,$4`
  style operands were linked as ->h1 relocs, so Open,
  Close-helper and Expunge read SysBase from h1+4 where
  initfn stored it — no absolute-$4 reads; fails only if
  vectors run without InitResident.
- **Code in DATA hunk:** h1+0x18 holds an executable stub
  `addq.l #1,(a1); moveq #0,d0; tst.l d0; rts` (the
  `tst.l` is redundant), registered as a tick callback via
  toolkit -228 at -60 entry. Mixing code into the data
  hunk is unusual but works since it's never I/D-split.
- **Scrambled RELOC32 order:** the single reloc block is
  emitted 0xce,0xca,0xd2,0xc2,0xc6,0xbe,0xd6,0xda, then
  resident/inittab, then code slots — non-monotonic
  linker ordering, spliced verbatim.
- **Mixed ABIs:** -36 takes both args on the stack (gcc
  convention); all other vectors take register args.
- All 12 vectors + init/open/close/expunge traced clean
  under stubs (0 invalids); orig vs rebuild BYTE-IDENTICAL
  and RUNTIME-IDENTICAL.
