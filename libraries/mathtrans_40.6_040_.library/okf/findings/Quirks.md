---
type: Finding
title: Quirks
description: Oddities found in the shipped binary.
---

# Quirks

1. **RT_ENDSKIP points at the InitTable** (hunk+0x6e), not
   module end — same as all sibling 40.6 builds; harmless
   but unusual.

2. **`mulul` with a nonstandard extension word** in the
   `_pow_int` integer-power path: shipped bytes
   `4c05 1001` where canonical gas emits `4c05 1000`.
   The extra bit is ignored by the CPU (MULU.L #d1# field
   variants are don't-care) — preserved verbatim as
   `.word 0x4c05,0x1001` in the reconstruction.

3. **`_czero` is a 4-byte long, not a double** — the
   constant pool tail emits only `0x00000000` for zero;
   code that needs fp zero uses `fmovex` of a zeroed
   register or the long via integer load.

4. **PC-relative FPU references encode displacement from
   insn+4** (the operand-extension word address), a
   convention GNU as reproduces differently — the
   reconstruction emits the shipped displacement values
   verbatim as `%pc@(literal)`.

5. **Alignment `0000` words** appear before several
   branch targets (`orib #0,d0` when executed, but they
   are unreachable pads); preserved as `.word 0` so the
   region stays byte-exact.

6. **FFP error convention inherited**: SPFieee returns
   0xFFFFFFFF + V flag on overflow/unrepresentable;
   NaN-producing inputs (log of <=0, asin/acos |x|>1)
   feed the IEEE NaN constant 0x7fffffffffffffff into
   SPFieee, yielding the error FFP value.

7. **DELEXP lives in a private byte** at base+0x2a bit3,
   not lib_Flags — same as the sibling 40.6 builds.

8. **Init gate differs from the FPU sibling**: requires
   AFF_68040 always, and AFF_FPU40 when exec >= V39 —
   even though all transcendental math is in software
   (fsqrts/fint-level ops are still FPU instructions).
