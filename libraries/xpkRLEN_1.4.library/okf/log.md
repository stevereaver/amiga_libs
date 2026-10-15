---
type: Log
title: Work journal
---

# Log

## 2026-10-10

- `make clean && make` in `source/` — built first try (two-pass
  genfunctab link).
- Reviewed `xpkRLEN.c`/`xpkRLEN_lib.s` against
  `work/xpkRLEN_1.4_020.asm`: encoder state machine (lit/pend/runlen,
  4+pend reserve check, ≥3-byte run seeding, 127 caps), decoder
  (0x80 quirk, no output bounds), Expunge/Close flow — all faithful.
- Fixed two fidelity bugs: `RT_ENDSKIP` pointed inside the hunk —
  added `endmodule.o` linked last so `_endcode` lands at module end
  as in the original (0x278); Makefile header comment said "V1.5",
  corrected to 1.4.
- Compared rebuild vs original: byte-identical through +0x0c
  (RT_ENDSKIP value), tables/descriptors equivalent at different
  offsets.
- Wrote the okf bundle.

## 2026-10-15

- Byte-identical reconstruction: wrote `source/xpkRLEN_h0.s`, a
  verbatim gas transcription of the whole 0x278-byte code hunk
  (stub, RomTag, InitTable, functab, datatab, strings, all code,
  XpkMode/XpkInfo islands).  `make` links it and `source/fixup.py`
  re-sorts the RELOC32 table descending; `cmp` reports
  BYTE-IDENTICAL, md5 `63d5fd7d33d88c97157f13a5540b865b`.  gas
  emitted `cmpi` for two `cmp #imm,Dn` forms — raw `.short` words
  used instead.
- Runtime oracle: `work/oracle.py` (machine68k, adapted from
  xpkDLTA_0.2) runs the AUTOINIT InitStruct, all ten vectors, a
  212-byte mixed literal/run pack, round-trip unpack, the 0x80
  token, zero-length pack/unpack, the -17 reserve error and
  deferred+real expunge.  orig.log == rebuild.log.
  (`m.execute()` defaults to max_cycles=1000 — byte-at-a-time
  codecs need an explicit budget.)
- Corrected [Decoder80](findings/Decoder80.md): the 0x80 token does
  NOT decode to nothing — `neg.b` of -128 sets V so the `ble` falls
  through, one byte is emitted, then `subq.b` wraps and V kills the
  `bgt` loop.  Verified on the oracle.
