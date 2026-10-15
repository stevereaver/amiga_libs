---
type: Finding
title: Rebuild deviations
description: Byte-level differences between the original and the rebuild.
timestamp: 2026-10-15T00:00:00Z
---

# Rebuild deviations

None — `make` in `source/` now produces a **byte-identical** image
(md5 `2e211c29f976ac2b702beb812a9f3914`, sha256
`c1aedc8eee7a5fa478adfdaf8a6d3240931f35f9f88e2c55305521741951f92e`).

The byte-exact build is `xpkNONE_h0.s`, a verbatim assembly
reconstruction of the single CODE hunk (0x20c bytes). The earlier C
model (`xpkNONE.c` + `xpkNONE_lib.s` + `genfunctab.py`) is kept as a
readable reference but was never byte-identical (.text 0x230, gcc
codegen and object link order differed).

Two original-image details required verbatim emission:

- `rt_EndSkip` stores literal `0` with **no relocation** — the
  resident's endskip field is just zero, not a relocated pointer to
  the hunk base. Emitting `.long _stub0` produced a spurious 18th
  RELOC32 entry.
- `movea.l 0(a0),a0` in the -54 vector uses the 6-byte disp16 form
  (`2068 0000`); gas canonicalizes `0(a0)` to the 2-byte `(a0)`
  indirect, so it is emitted as raw `.short`s.

Runtime: `work/oracle.py` gives identical traces for the original and
the rebuild across init, Open x2, all four reserved stubs, XPKInfo,
the -17 vector, the CopyMem vector, and deferred + real expunge.
