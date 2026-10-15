---
type: Log
title: geclass_37.6 work log
---

# Work log (newest first)

## Final pass — oracle parity + OKF docs

- Re-ran `work/oracle.py` on `binary/geclass_37.6.library`
  (`work/orig.log`) and `source/geclass.library` (`work/new.log`):
  **logs identical** (85 entries), covering init success, init
  dep-fail longjmp (utility.library absent -> cleanup of the three
  already-open libs, return 0, latch set), iff.library absent
  (init ok, txtcl=0), all six vectors, OM_NEW default/tag/NULL-obj/
  super-fail paths, IM_DRAW pen selection (state==1 -> pens[6],
  else pens[2], no drinfo -> 0/1), supermethod passthrough for
  0x77/0x103/0x203, name remapping for getfileiclass/textfieldgclass
  /unknown/NULL, DisposeObject passthrough, close->busy-expunge->
  deferred-expunge (Remove/FreeClass/CloseLibrary x5/FreeMem,
  returns seglist).
- Rebuilt via `make` after `make clean`: `source/geclass.library`
  md5 `bfecf92799ad9ca83f6a1907af676830` — identical to the
  original.  Wrote all five OKF documents.

## Oracle bring-up

- Adapted `libraries/recent_0.9.library/work/oracle.py`: hunk
  loader + REL32 application, trap-stubbed library bases for
  exec/intuition/graphics/utility/iff, fake superclass class whose
  `cl_Super` dispatcher is a trap, hand-run AUTOINIT (datatab
  walker + functab jump-table vectors).
- Bug: standalone failure-path test invoked the InitTable pointer
  itself instead of `InitTable+12` (init function) — produced
  garbage `INVALID` writes.  Fixed by resolving `r32(it+12)`.
- Bug: `fail_main` appended to a stale `LOG` name after reloading —
  fixed to use each environment's own `LOG`.
- Result: dep-fail returns 0 with the cleanup latch set;
  no-iff returns the lib base with txtcl/iff NULL.

## Byte-identical reconstruction

- Parsed the hunk header: 2 hunks — h0 CODE 0x2bb longs (0xaec
  bytes), h1 BSS 0x30 longs.  Captured both RELOC32 groups exactly:
  16 h0->h0 offsets in descending order, 7 h0->h1 offsets.
- Disassembled h0; identified RomTag@4, name@0x1e, idstr@0x3e,
  InitTable@0x7e, datatab@0x8e, functab@0xba (6 absolute vectors),
  code from 0xd8, dispatcher jump table, border coordinate table,
  and all embedded strings.
- Transcribed to `source/geclass_h0.s` (raw `.short`/`.long` where
  GAS canonicalises differently: `mov.l #48,d2`, absolute
  `lea _bss:l`, `rtd`, `trapf`, the `pea 0xff:w` bound pushes, the
  word-offset jump table) and `source/geclass_h1.s` (BSS).
- `source/Makefile` builds with `-m68000`, links via generated
  `hunks.x` section script, then `fixup.py` rewrites the hunk
  records: h1 -> pure HUNK_BSS (drop zeroed body GNU ld emits for
  .bss), h0 RELOC32 re-emitted in the original group order.
- First build after padding fixes (35-byte pad after id string ->
  InitTable at 0x7e; 1-byte pad near the iff.library string) matched
  byte-for-byte: md5 `bfecf92799ad9ca83f6a1907af676830`, 2964 bytes.

## Identification

- `geclass.library` 37.6, id `GEClass 37.6 (16 Dec 1994)`.
- BOOPSI helper: makes a private `frameiclass` subclass reachable as
  `getfileiclass`, pulls `textfieldgclass` from `iff.library` -30,
  exports NewObjectA/DisposeObject wrappers.
- No matching public sources located; reconstructed purely from the
  binary.
