# Work log

- Reused work/*.asm disassembly
- C reconstruction (prior agent), verified `make clean && make`
- XPK LVOs resolved against xpk_Develop xpksub_lib.i / xpksub.h
- OKF bundle written

## 2026-10-15 — byte-identical asm reconstruction

- Prior okf claimed "Non-AUTOINIT; absolute-longword function table" —
  wrong: the binary is AUTOINIT (RomTag flags 0x80) with the same
  word-offset functab format as xpkNONE 1.5 (0xffff marker, signed
  word offsets, -1 terminator).  Null slots point at the shared
  `moveq #0,d0/rts` at code+0x20a INSIDE XpksPackChunk.
- Added `source/xpkDLTA_h0.s`: verbatim GNU-as emitting the whole hunk
  — entry stub, RomTag (rt_EndSkip relocated to the trailing `nop`),
  strings, InitTable, word-offset functab, the big InitStruct datatab
  that builds XpkInfo@base+0x26 and XpkMode@base+0x7e (offset bytes
  0x82/0x9e/0xa2 are flat byte offsets, not extended), all six real
  vectors.
- Raw-emitted `b2bc 0001 0000` for `cmp.l #0x10000,d1` (avoiding any
  `cmpi` canonicalisation).
- Reloc tail fix: the shipped 17-entry reloc32 block is DESCENDING —
  `source/fixup.py` rewrites the linked hunk's table in place.
  Result: md5 `db80a6f55766ec0e670a7a78b441920e`, byte-identical.
  C model kept as `make cmodel` (superseded; see
  findings/RebuildDelta.md).
- `work/oracle.py` (machine68k): AUTOINIT + word-offset functab
  decode, exec Remove/FreeMem stubs; drives init (seglist store +
  xi_ModeDesc link to base+0x7e), Open x2, reserved stubs, XpkInfo
  dump at base+0x26, Pack/Unpack round-trips including the
  xsp_Sub[0]/[1] chunk carry, both error paths (-10/-11),
  close/deferred/real expunge.  orig.log == rebuild.log —
  RUNTIME-IDENTICAL.
- Codec observations: bounds checks return -10 (InLen>OutBufLen) /
  -11 (InLen>64K); **the byte loop is off-by-one** — it consumes and
  produces InLen+1 bytes while reporting OutLen=InLen (oracle
  verified on the shipped binary); the carry longword stored to
  xsp_Sub[1] keeps d0's upper bytes; InLen==0 wraps to a ~64K-byte
  overwrite.
