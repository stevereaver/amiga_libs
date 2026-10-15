# Work log

- Reused work/*.asm disassembly
- C reconstruction (prior agent), verified `make clean && make`
- XPK LVOs resolved against xpk_Develop xpksub_lib.i / xpksub.h
- OKF bundle written

## 2026-10-15

- Byte-identical reconstruction: wrote `source/xpkRLEN_h0.s`, a
  verbatim gas transcription of the whole 0x2bc-byte code hunk
  (stub, RomTag, strings, InitTable, datatab, functab, all code,
  XpkInfo/XpkMode islands).  `make` links it; `cmp` reports
  BYTE-IDENTICAL, md5 `e0f7d2275b0331a7a0c86f88123671ed`.  The
  original's RELOC32 tail is already ascending (GNU ld order), so
  unlike 1.4 no fixup step is needed.  Two raw `.short` spots:
  `moveal a0@(0),a1` (gas canonicalises away the 0 disp) — there are
  no `cmp #imm,Dn` forms in this build.
- Corrected the stale okf claim "Non-AUTOINIT / absolute-longword
  function table": rt_Flags=0x80 (RTF_AUTOINIT), the InitTable at
  hunk+0x68 points at a word-offset functab at hunk+0x98 whose dead
  slots hold -0x98 back to the entry stub.
- Runtime oracle: `work/oracle.py` (machine68k, adapted from
  xpkDLTA_0.2) exercises init, all ten vectors, compressible pack,
  round-trip unpack, the 0x80 token (emits 128 bytes here), the -17
  refusal on incompressible AND zero-length input (output ceiling =
  OutBuf + InLen; xsp_OutBufLen is never read), and deferred+real
  expunge.  orig.log == rebuild.log.
- Confirmed version deltas vs 1.4: $VER added, endskip 0x278->0,
  dataSize 0x2a->0x26 (unused long dropped), masterv 0->2,
  defchunk 0x4004->0x8000, defmode 50->100, new encoder/decoder,
  reloc tail descending->ascending.
