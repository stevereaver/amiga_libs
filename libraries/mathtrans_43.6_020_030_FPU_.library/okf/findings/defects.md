# Defects / quirks — reproduced, not fixed

1. **OpenCnt seeded to 1 at init.** `_Init` writes `movew #1,lib+0x20`.
   Since Open/Close pair off symmetrically, OpenCnt can never reach 0 via
   normal use → `Close` never triggers a deferred expunge; the library can
   only be expunged by an explicit `Expunge` with OpenCnt still == 1
   (which takes the deferred-branch and returns 0 — it won't actually
   expunge either since the count check reads 1!).  Net effect: the lib
   is effectively unexpungeable via the normal interface.  Verified in
   the oracle: `expnge` with OpenCnt=1 returns 0 and only sets
   LIBF_DELEXP; only forcing OpenCnt=0 expunges.

2. **SPPow mantissa corruption.** At +0x184: `andib #0x7f,%d0` — applied
   to the *expanded* IEEE single, this clears bit 7 of the mantissa low
   byte rather than the sign bit (bit 31).  Intent was presumably
   |base| for `flogn`; the actual effect is a 1-ulp-class mantissa tweak
   and the sign is NOT cleared (negative base still → NaN-class path).
   Reproduced verbatim.

3. **Unreachable/error CCR convention.** The saturation tail does
   `moveq #-1,d0; lsrb #1,d0; orib #2,%ccr` — returns 0x7fffffff and
   sets CCR bit1 (Z on a real 68k reads as the Z flag... the `orib #2`
   sets the Z bit directly).  Callers expecting a normal IEEE error
   scheme get a flagged 0x7fffffff.

4. **DREL16 toolchain artifact.** Original reloc hunks are DREL16 with
   offsets in *reverse* order and a word terminator + pad — output of a
   non-GNU linker (likely PhxAss/vlink-era).  Reproduced byte-exactly by
   `source/drel16.py` post-link fixup.

5. **`rt_EndSkip` points at the last nop** (0x972), not past it — the
   final `4e71` at +0x972 is outside the resident's declared end.
   Reproduced.
