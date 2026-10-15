---
type: Log
title: Work journal
---

# Log

## 2026-10-10

- Verified the reconstructed `source/` builds clean (`make clean &&
  make`): two-pass link, `genfunctab.py` emits the word-offset
  function table; single-hunk `xpkNONE.library` produced.
- Moved the stray IRA dump `source/xpkNONE.asm` into `work/` (asm must
  never live in `source/`).
- Reviewed `xpkNONE.c`/`xpkNONE_lib.s` against
  `work/xpkNONE_1.5_000__020.asm`: entry stub, RomTag, InitTable
  (dataSize 0x26), InitStruct data, word-offset functab with -1
  marker, Expunge/Close/Open order, CopyMem unpack, descriptor
  contents — all match. No semantic fixes needed.
- Compared rebuild vs original: byte-identical through +0x68; table
  order and all embedded data equivalent; code offsets differ.
- Wrote the okf bundle.

## 2026-10-15

- Replaced the primary build with verbatim asm `source/xpkNONE_h0.s`:
  entry stub, RomTag, name/id strings, InitTable, InitStruct datatab,
  word-offset functab, all six real vectors, XpkInfo/XpkMode islands
  and strings emitted byte-for-byte. `make` output is now
  byte-identical to the original (md5 `2e211c29f976ac2b702beb812a9f3914`).
- Quirk confirmed while matching the reloc tail: `rt_EndSkip` stores
  literal `0` and carries **no** RELOC32 entry (17 relocs total, none
  at +0xa).
- Raw-emitted `2068 0000` for `movea.l 0(a0),a0` (disp16-zero form;
  gas folds it otherwise).
- Wrote `work/oracle.py` (machine68k): AUTOINIT + word-offset functab
  (signed decode — reserved slots encode negative offsets back to the
  code+0 stub), exec Remove/FreeMem/CopyMem stubs. Original and
  rebuild traces identical: init stores seglist at lib+0x22; Open x2;
  reserved stubs return 0; -30 returns the CODE+0x13c XpkInfo island
  (sign "NONE", "NoPacker", description); -36 returns -17
  (`0xffffffef`); -54 does CopyMem(src,len,dst) via the param block
  and stores len at pb+16; close/deferred/real expunge with
  Remove+FreeMem(lib-24,132).
