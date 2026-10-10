# mathffp.library 36.5 — defects & quirks (all shipped behavior)

1. **Denormal divisor → hardware divide-by-zero trap loop.**
   `SPDiv` checks only `d1.b==0`; a nonzero denormal divisor
   (byte 0, mantissa set) executes `divu.w #0,d0` — a real
   divide-by-zero exception. If the trap handler returns, the
   code re-tests d1 and re-enters, trapping forever. Exact
   zero → saturated 0xffffff7f +V instead.

2. **SPDiv exp-overflow saturate takes the DIVISOR's sign.**
   The `bvs 0x3e2` path un-swaps d0/d1 then `eor.b d1,d0`, so
   the result byte becomes the divisor's exponent byte — the
   saturated ±0xffffff7f carries the divisor's sign bit, not
   the mathematical result sign. (The earlier 0x3ea path does
   produce the proper sN^sD sign.)

3. **Close never auto-expunges.** `LibClose` decrements
   opencnt and returns 0 when it hits zero; the DELEXP check +
   Expunge call only runs while opencnt > 0 — where Expunge
   just re-sets DELEXP. Standard libs expunge on last close;
   this one deadlocks the flag instead.

4. **Expunge frees raw memory, returns 0.** ROM-era pattern:
   unlinks the node and FreeMem()s the library area; no seglist
   is returned (disk-loaded instances leak their hunks).

5. **Denormal (byte-0, mantissa-nonzero) leaks:**
   - `SPNeg` returns denormals unchanged (`tst.b/beq` guards
     only the eor).
   - `SPAbs` clears bit7 unconditionally — turns a negative
     denormal into a positive denormal.
   - `SPFix`/`SPFloor` return byte-0 inputs unmasked.
   - `SPMul` with byte-0 B returns B as-is; byte-0 A → 0.
   - add/sub return `d0`/`d1` unmodified when the other
     operand's byte is 0 — a denormal is returned verbatim,
     sign byte included.

6. **SPMul rounding wrap.** The `+0x80` round on the normalized
   path can wrap the whole 32-bit product (d0=0xffffff80+ → 0);
   byte merge still applies. Extreme edge only.

7. **SPDiv borrow-correction adds the full divisor** (exponent
   byte included) to the remainder, relying on carry-out for
   termination — correct but sloppy.

8. **ExtFunc (-24) returns garbage.** Points at the bare `rts`
   shared with InitFunction; d0 on return is whatever the
   caller left in it.

9. **dbmi-loop exponent underflow guard is byte-sized.** The
   normalize loops use `dbmi` (exit at -1) plus a sign-flip
   check; counts wrap mod 256, fine for real inputs.

10. **Copyright banner hunk.** Hunk1 contains only the
    Motorola MC68343 copyright string. The reconstruction uses
    a same-length placeholder note — the verbatim notice is not
    committed (copyright hygiene); the generated library is
    gitignored anyway.
