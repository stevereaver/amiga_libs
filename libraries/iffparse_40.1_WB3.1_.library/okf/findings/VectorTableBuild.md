---
type: Finding
title: Word-offset functable cannot be emitted directly by gas
description: Toolchain limitation and the two-pass build workaround.
timestamp: 2026-10-10T18:00:00Z
---

# Functable build workaround

The AUTOINIT table needs `.word func - functab` entries.  When
`func` lives in a different object than the table, m68k-amigaos gas
resolves the expression to a RELRELOC16 relocation — semantics
"target minus *relocation position*" — which silently produces
wrong values (verified: stored = T - P - functab_off).

gas also rejects `func-.` and `func+.-label` outright ("invalid
operands *UND* and .text").

## Workaround (implemented in source/Makefile)

1. Link once with `functab_stub.o` — a same-size dummy table
   (marker + 45 zero words + terminator).
2. Read final symbol addresses with `m68k-amigaos-nm`.
3. `genfunctab.py` emits `functab.s` with literal `.word` offsets
   (`func_addr - functab_addr`).
4. Relink.  Sizes are identical between passes so addresses are
   stable.

All 45 resulting entries were verified to decode to the correct
function symbols.
