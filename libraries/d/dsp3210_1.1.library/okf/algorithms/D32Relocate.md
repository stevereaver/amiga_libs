---
type: Algorithm
title: D32 relocation
description: How DSPRelocate transforms a linked d32 image into a loaded one.
timestamp: 2026-10-10T20:10:00Z
---

# D32 relocation

Two passes over the section table:

**Pass 1 (load).** Sections land contiguously at `target`, each padded
to a 4-byte boundary (`align4(size)` — the total DSPCalcLen computes).
A `ULONG[nsec]` table of load addresses is built for pass 2.

**Pass 2 (fixup).** For every reloc record `{patchOff, symIdx, type}`:

1. Symbol resolution:
   - `sym.value` for an internally defined symbol (sect > 0) is a
     *linked* address in the defining section's address space; the
     runtime value is `value - linkedBase(sect) + loadBase(sect)`.
   - `sect == 0` means external: resolve by name against the caller's
     `{name,value}` array. Name comes from inline bytes at sym+0
     (when nonzero) or `strtab + u16(sym+6)`.
   - `sect < 0` → error -20; unresolved external → -21.
2. Patch (at `loadBase(curSection) + patchOff`):
   - `0x2c` — store all 32 bits
   - `0x2e` — store low 16 bits at +2
   - `0x2f` — store high 16 bits at +2
   - `0x1c` — store low 16 bits at +2, then error -30 if the value
     doesn't fit (the write happens *before* the check)
   - anything else → -10

The +2 offsets reflect the DSP3210's 32-bit word granularity: an
address in a d32 instruction lives in the low bytes of a 32-bit word,
so 16-bit fixups land at +2 within it.
