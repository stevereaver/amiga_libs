---
type: Log
title: xpkMASH_1.98(000) work log
timestamp: 2026-10-14T00:00:00Z
---

# Work log (newest first)

## Randomized differential test + oracle consolidation

- `work/randtest.py` ported to the Lib-class oracle and run with
  N=150 (740 case×mode comparisons: random/periodic/text/runs/
  near-incompressible inputs up to ~100KB incl. inputs >64KB that
  force the engine-B fallback): **0 failures** — packed streams and
  unpack round-trips byte-identical orig vs rebuild.
- One earlier randtest run reported spurious garbage-return-code
  diffs (rc values like 30/518, stale OutLen sentinels) that did not
  reproduce on re-run — orig-vs-orig emits are identical and the
  clean driver run passes 740/740.  Treated as a transient
  harness/machine68k artifact, not a real divergence: the binaries
  are byte-identical, so equal execution is guaranteed.
- `work/oracle.py` consolidated to the Lib-class API used by
  `run_oracle.py`/`difftest.py`/`randtest.py` (the earlier
  function-based load()/makelib() variant is superseded).

## Byte-identical reconstruction achieved + verified

- Transcribed the entire code hunk via capstone disassembly ->
  devin-syntax assembly (`work/genasm.py`).  Authored resident
  header/RomTag/InitTable/InitStruct/XPK-info/mode-block around it.
- Assembled+linked with `m68k-amigaos-gcc -m68000 -nostdlib
  -nostartfiles -Wl,-s` (the -s drops the HUNK_SYMBOL the linker
  appends; without it a 0x3f0 block follows the code hunk).
- Iterated `work/fixup.py`: assemble -> byte-compare hunk bodies ->
  emit the first mismatching instruction as `.short` -> repeat.
  Then `work/minimize.py` dropped stale patches; 13 remain
  (`work/patch000.txt`), all two devin encoding limitations:
  `movea.l $0(An),Am` (devin drops the explicit zero displacement)
  and `move.b (Ax)+,(Ay)+` (the mem-to-mem byte copy).
- Result: `source/xpkMASH.s` builds BYTE-IDENTICAL to
  `binary/xpkMASH_1.98(000).library` — full file compare clean.
- `work/run_oracle.py` under machine68k: lifecycle
  (open/open/expunge-deferred/close/close -> Remove+FreeMem),
  PackerInfo descriptor dump, 20-case x 2-mode corpus -> 40 .pk
  streams, unpack round-trips, alloc-fail (-7) and partial-alloc
  (halving loop) paths.
- `work/difftest.py` runs orig vs rebuilt in SEPARATE processes —
  machine68k trap dispatch is global per tid; two `Lib` objects in
  one process clobber each other's AllocMem/endtrap handlers and
  corrupt results (observed: stale-handler runs returning zeroed or
  off-by-one-byte streams).  Diff: reports identical modulo the
  binary path; all 40 streams byte-identical.

## Earlier (previous session)

- Hunk maps recovered: 000 = 2652-byte code hunk + 28 RELOC32.
- Runtime probe captured: 300x'Z' -> 6-byte stream bf5ac5202000;
  AllocMem(131688) + FreeMem pattern.
- Region map, functab order, XPK descriptor and mode record
  decoded; C reference transliteration written
  (`work/xpkMASH_ref.c`) documenting both engines and all defects.
- First C-rebuild attempt produced a working but non-identical
  library; superseded by the asm transcription which is byte-exact.

## Remaining notes

- The `.s` is the shipped reconstruction; `work/xpkMASH_ref.c`
  documents the algorithm for readers but is not built.
- Generator inputs: patch files pin the 13 raw-word sites; removing
  one changes bytes -> fixup.py re-adds it.
