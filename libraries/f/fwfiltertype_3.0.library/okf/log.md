---
type: Log
title: Work journal
---

# Log

## 2026-10-15

- Replaced the C reconstruction with `source/fwfiltertype.s` — verbatim
  asm. `make` -> BYTE-IDENTICAL (md5 e6e1ad2915d73de079e659eeabf4ac58).
- `fixup.py` rewrites RELOC32 offsets descending (original order).
- Corrections verified by oracle: the compare is **5 bytes** ("alpha",
  not "alph"); `*out` IS cleared on miss via a mid-instruction `clr.l
  (a4)` hidden inside a `cmpi.w #$4294,d0` extension word; return
  carries stale upper-16 bits; `rt_EndSkip` points at the initfn
  (0x138), not module end; IdString fields point past "$VER: ".
- `work/oracle.py` (machine68k): InitStruct + absolute functab decode,
  exec Remove/FreeMem stubs, FwFilterType match/miss/a1=NULL fixtures.
  orig vs rebuild: RUNTIME-IDENTICAL.

## 2026-10-10

- Disassembled binary (ira -M68000 → work/fwfiltertype_3.0.asm); decoded
  RomTag, InitTable (dataSize 0x28, absolute-long functab) and compact
  InitStruct stream.
- Resolved all 6 LVO slots: standard skeleton (Open/Close/Expunge/Null)
  + FwFilterType at -30 + second reserved null at -36.
- Reconstructed C source (fwfiltertype_lib.s + fwfiltertype.c +
  fwbase.h); `make` builds a single-hunk .library with identical header
  layout and InitStruct bytes.
- Documented findings: dead cmpi, idstring-inside-$VER trick, unused
  third arg, unknown caller contract.
