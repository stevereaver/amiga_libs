---
type: Finding
title: RebuildDeviations
description: Where the reconstruction differs from the shipped binary.
timestamp: 2026-10-10T19:00:00Z
---

# Rebuild deviations

None.  `source/asdg_h0.s` is a byte-verbatim reconstruction: the
linked hunk is identical and `source/fixup.py` rebuilds the
envelope (3-hunk header declaring CODE + two empty hunks, empty
DATA/BSS trailer hunks).  `make` output compares equal to the
shipped binary (`cmp`), and the `machine68k` oracle
(`work/oracle.py`) logs identical traces for every vector:
init/Open x2/Close(-to-expunge)/Reg/DeReg/query/alert-trigger,
including the dup (-1) and AllocMem-fail (-2) paths.

The historical C reconstruction remains available as
`make cmodel` (functionally equivalent, not byte-identical --
it is 0x31c bytes and emits no empty DATA/BSS hunks).
