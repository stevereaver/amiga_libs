# Work log

- Reused work/*.asm disassembly
- C reconstruction (prior agent), verified `make clean && make`
- XPK LVOs resolved against xpk_Develop xpksub_lib.i / xpksub.h
- OKF bundle written

## 2026-10-15 — byte-identical asm reconstruction

- Prior okf claimed "Non-AUTOINIT; absolute-longword function table" —
  wrong: the binary is AUTOINIT (RomTag flags 0x80) with the same
  word-offset functab format as xpkNONE 1.5 (0xffff marker, signed
  word offsets, -1 terminator).
- Added `source/xpkDLTA_h0.s`: verbatim GNU-as emitting the whole hunk
  — entry stub, RomTag (rt_EndSkip literal 0, deliberately
  unrelocated), strings, InitTable, InitStruct datatab, functab, all
  six real vectors, XpkInfo/XpkMode islands and string pool.
- Raw-emitted `2268 0000` for `movea.l 0(a0),a1` (gas folds the
  disp16-zero form otherwise).
- `make` now produces md5 `7c59a56bf765719b0e755acc854bfa4c` —
  byte-identical to the shipped binary (reloc tail already ascending,
  no fixup needed).  C model kept as `make cmodel` (superseded; see
  findings/RebuildDelta.md).
- `work/oracle.py` (machine68k): AUTOINIT + word-offset functab
  decode, exec Remove/FreeMem stubs; drives init, Open x2, reserved
  stubs, XpkInfo dump (incl. embedded XpkMode), PackChunk/UnpackChunk
  round-trips on two buffers, close/deferred/real expunge.
  orig.log == rebuild.log — RUNTIME-IDENTICAL.
- Codec observations from the trace: pack writes xsp_OutLen=InLen and
  always returns 0; **unpack never writes xsp_OutLen** (quirk); no
  OutBufLen/64K bounds checks (dropped vs 0.2); no xsp_Sub carry
  (dropped vs 0.2); InLen==0 would run away — do not feed zero-length
  chunks.
