# Work log

- Reused work/*.asm disassembly
- C reconstruction (prior agent), verified `make clean && make`
- XPK LVOs resolved against xpk_Develop xpksub_lib.i / xpksub.h
- OKF bundle written

## 2026-10-15

- Verbatim asm reconstruction `source/xpkNONE_v.s` — byte-identical
  (md5 56927e0ddec34be4998faff61ca18e2c).  fixup.py reorders the
  RELOC32 group descending (29 offsets).
- machine68k oracle RUNTIME-IDENTICAL: init (seglist -> code+0x7a
  cell), Open x2, all four null stubs, XPKInfo island (ver 1.1,
  sig/name/desc/status strings, ext struct "normal"/0x77e/0x9ad),
  -36 -> -17, CopyMem passthrough, deferred expunge writing the flag
  to EXEC+0xe (defect — lib never expunges via Close), direct
  expunge -> Remove+FreeMem(94,128)+seglist.
- New quirks vs 1.5: long (not word-offset) functab; rt_EndSkip=0x102
  truncates the resident before all strings; dataSize=0x22 only.
