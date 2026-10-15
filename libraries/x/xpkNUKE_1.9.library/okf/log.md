---
type: Log
title: xpkNUKE_1.9 work log
timestamp: 2026-10-14T00:00:00Z
---

# Work log (newest first)

## Final pass — verification re-run + findings rename

- Re-ran `work/oracle.py` against `binary/` (tag O) and
  `source/xpkNUKE.library` (tag M): 20/20 packed streams in
  `work/streamsM/` byte-identical to `work/streamsO/`; normalized
  oracle logs identical except descriptor-internal code offsets
  (relocated pointers — all referenced content identical).
- Rebuilt target with `make` (`-m68000`, two-pass functab): clean.
- Renamed `okf/findings/quirks.md` -> `defects.md` to match the
  deliverable layout used by SQSH/ZENO/HUFF/BZIP/TDCS.
- Repo-wide MD5 scan: `07c317d397b2b2c02945cf034c89225a` is unique.

## 2026-10-14 — packer match-gate resolved, full byte-parity

- Root-caused the last packer divergence (`txt`/`ramp`/`rnd8k`):
  offset `0x42a` is `bls` (`cmp.w d4,d6` = candidate <= window edge),
  **not** `bcs`.  With `d4` clamped to 0 inside the window, the gate
  rejects the tab2[0] sentinel candidate and boundary positions.
  Earlier trap-patching of the conditional branches corrupted flags
  and produced misleading traces.
- m68k build (`-m68000`) + -m32 host build both emit byte-identical
  pack streams vs the original on the full 20-case corpus
  (empty/1B/2B/lit16/lit40/z64/z300/z40k/ab_rep/abc/abab/txt/allb/
  rep4k/rep30k/snd/ramp/rnd1k/rnd8k/mix); unpack round-trips match,
  including the original's z40k non-round-trip quirk.
- PackFree, realloc-pack, tiny-outbuf, deferred expunge and the
  PackerInfo descriptor all verified identical (addresses aside).

## Earlier sessions

- Original xpk 1.9 sources (NUKE.a/xpkNUKE.c) recovered from Aminet
  `xpk_Source.lha`; used to confirm algorithm intent.  The shipped
  binary still had to be matched instruction-by-instruction (several
  deltas vs that source: clear ranges, sentinel gate, nlits math).
- Fixed reconstruction bugs: SHORT typedef, clear range +40..+63,
  acc4/ptr seeding, `~(len-3)&3` short-length code, contiguous
  clstab at 0x17c (at[16]/at[32] index the same table), exact
  `nlits.w` copy count, sign-extended addaw for litptr/srcend.
- Lifecycle moved to `xpkNUKE_lib.s` (a6 lib-base convention);
  FreeMem invoked through inline asm to preserve return value.
