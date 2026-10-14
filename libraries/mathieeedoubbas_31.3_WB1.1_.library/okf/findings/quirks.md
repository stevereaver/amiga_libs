# mathieeedoubbas 31.3 — quirks & defects

## Shipped defects (preserved verbatim)

- **Overflow sentinel is not IEEE infinity.** `mul(1e200,1e200)` and
  `div(x,0)` return `0x7fffffffffffffff` (all ones) rather than
  `0x7ff0000000000000`. Add's overflow path uses the same sentinel.
- **`IEEEDPFix` overflow returns garbage.** `fix(1e300)` returns
  `0x0000006b` — a shifted residue of the mantissa loop, not a clamped
  or flagged result.
- **Subnormal multiply collapses to zero.** `mul(5e-324,2)` returns
  `+0.0`; the multiply path does not denormal-align operands whose
  exponent field is 0 (add *does*, via its `subql`-primed shift loop).
- **Dead code falls off the hunk.** Unused dispatcher selector values
  reach hunk2+0x48e (`movel #224,d1`) with no terminating `rts`.
- **Null `ln_IdString`.** InitTable `dataSize` is 0x22, so the built
  library node's IdString field (+24) is never initialized.
- **Self-modifying code.** The three argument scratch cells
  (`_scr0/_scr1/_scr2` at hunk1+0x27c/0x284/0x28c) are data inside a
  CODE hunk — written on every vector call. Requires writeable code
  memory (fine on real 1.1 systems; matters for emulators/ROM).

## Reconstruction quirks

- The original assembler emitted long-form `movel #imm` where GAS relaxes
  to `moveq` (`#10`, `#9`, `#20` in the multiply loop preambles) — the
  reconstruction emits explicit opcode words + `.long` immediates.
- Loop labels straddle instructions: the add-path denormal-align loop
  `dbf`s back to the `asrl` one instruction *after* the `subql` that
  also serves as the branch target for the >=53-shift entry. Both
  landing sites are real and must keep their exact offsets.
- The div quotient loop is non-restoring: `blts` skips the restore block
  directly to the q<<1/bit-0 path, while the restore block's own `dbf`
  loops back to itself.
- `bras _add_pop` at the overflow tail deliberately skips the
  `tstl a0@` at `_add_ret` because `movew #3,%ccr` already set the ccr.
- The 5-entry hunk table (two trailing empty hunks) and the original
  RELOC32 *group order* (several same-target groups, some descending)
  are reconstructed by `source/fixup.py` after linking.
