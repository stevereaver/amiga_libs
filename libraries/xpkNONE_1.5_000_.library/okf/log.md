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
