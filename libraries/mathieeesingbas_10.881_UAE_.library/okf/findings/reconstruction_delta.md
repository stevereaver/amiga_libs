---
type: Finding
title: Reconstruction deltas
description: Rebuilt library vs shipped binary -- now byte-identical.
---

# Reconstruction deltas

None at the byte level: `source/mathieeesingbas.s` + `fixup.py` produce a
file identical to the shipped binary (md5 3e7f4b125c23ac45849af05ebcd587ce).

- Single `.text` hunk of 0x1c8 bytes transcribed verbatim: RomTag,
  AUTOINIT table, word-offset functab, InitStruct stream, init/Open/
  Close/Expunge stubs, strings, and all 12 IEEE-single entry points.
- The only post-processing is the reloc tail: GNU ld emits a standard
  HUNK_RELOC32 (0x3ec) record for the 8 absolute pointer fields, while
  the original was linked with the compact 0x3f7 record with 16-bit
  offsets in descending order (see [drel_tail.md](drel_tail.md)).
- The old multi-object C reconstruction is kept as `make cmodel`
  (functionally equivalent, not byte-identical).

Observed runtime semantics (machine68k oracle, `work/oracle.py`):

- `IEEESPCmp`/`IEEESPTst` share tails; `Cmp(d0,0)` branches into the Tst
  body; `Cmp` uses integer sign-magnitude tricks (incl. a `bset #31,d0`
  that turns +0 into 0x80000000 before the unsigned compare).
- `IEEESPAbs`/`IEEESPNeg` are pure integer ops (`bclr`/`bchg #31,d0`).
- `IEEESPFloor`/`IEEESPCeil` = `fintrz.s` + `fcmp.s` + FBcc +
  conditional `fsub/fadd #1.0`.
- Expunge unlinks the node inline (no exec.Remove call) and jumps into
  the shared free tail also used by the no-FPU init path.
