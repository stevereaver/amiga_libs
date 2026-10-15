---
type: Log
title: dpblit.library (DPBlitBase) work log
---

- 4 hunks: CODE0 0x27eL, DATA1 8L (InitTable at +4), DATA2|CHIP
  0x80L (zeroed blit buffer), CODE3 0xfL (functab + strings).
- Resident @h0+4: AUTOINIT v1 type9 pri0, name->h3+0x20
  'dpblit.library', idstr->h3+0x30 'DPBlitBase',
  init->h1+4 InitTable {dsz 0x50, ftab->h3+0, dtab 0,
  initfn->h0+0x20}; 7 absolute vectors.
- Verbatim transcription; branch-into-cmpi-operand copy tricks
  emitted as split .byte halves (L7c/Lba); objdump tail tokens
  spanning the data/code boundary grown over (initfn entry and
  L1d4 land inside byte runs).  Byte-identical first pass
  (md5 c3d70837f12093556ce3f98b54f2fbf3); fixup.py slices the
  single linked .text hunk back into the original 4-hunk layout
  and splices the original RELOC32 tails + header.
- Oracle: init logs openlib('graphics.library'), vectors -30/-36
  drive gfx -456/-228/-462 with A0=$dff000 (chip base from the
  hunk1 copy), -42 hits gfx-960 helpers; close x2 -> closelib +
  Remove + FreeMem on deferred expunge.  Identical original vs
  rebuild.
