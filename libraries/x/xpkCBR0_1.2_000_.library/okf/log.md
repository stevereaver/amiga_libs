# Work log

- Reused work/*.asm disassembly
- C reconstruction (prior agent), verified `make clean && make`
- XPK LVOs resolved against xpk_Develop xpksub_lib.i / xpksub.h
- OKF bundle written

## 2026-10-15 — byte-identical asm reconstruction

- Prior okf claimed "Non-AUTOINIT; absolute-longword function table" —
  both wrong: rt_Flags is 0x80 (RTF_AUTOINIT) and the functab is the
  Bilbo/Stoecker-style word-offset variant (0xffff lead/trail, signed
  word offsets from table base).  Null slots hold -0x8a = hunk+0, i.e.
  the entry stub `moveq #0,d0; rts` is the null vector.
- Added `source/xpkCBR0_h0.s`: verbatim GNU-as — RomTag
  (rt_EndSkip=0), strings, InitTable (datasize 0x26, datatab +0x6a
  physically before functab +0x8a), word-offset functab, initfn
  (stores seglist only), open/close/expunge (exec base via absolute 4,
  seglist kept in d2 — no stack juggling), ByteRun0 encoder, ByteRun1
  decoder, static XpkInfo/XpkMode island.
- `sub.l a5,d0` must be written `subl` (not `subal`) for gas.
- RELOC32 tail is ascending; GNU ld emits the same order — no fixup.
  Result: md5 `0243e290e331815dceb75ed3df6ccbed`, byte-identical.
- `work/oracle.py` (machine68k): word-offset functab decode, exec
  Remove/FreeMem stubs, execute(max_cycles=2e6) because the pack loops
  exceed the 1000-cycle default.  Drives init, Open x2, reserved stubs
  (all -> hunk+0), XpkInfo dump, mixed/literal/repeat pack+unpack
  round-trips, zero-length pack (-17) and unpack (0), overflow -17,
  deferred + real expunge.  orig.log == rebuild.log —
  RUNTIME-IDENTICAL.
- Codec observations: output bound is OutBuf+InLen (xsp_OutBufLen
  ignored); repeat-run detection triggers on a 3-equal streak with a
  4th-byte check and d2-capped 125 look-ahead; literal count byte is
  len-1, repeat count is -(len-1); a 200x run packs to \x81\x5a
  \xb9\x5a.
