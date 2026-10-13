# xpkSQSH 1.10 — vector map

Identical to xpkSQSH_1.00 (same code hunk). AUTOINIT, absolute-longword
functab (10 entries + -1), InitTable dataSize 0xa8, datatab
ln_Type=9/lib_Flags=6/version=1/**revision=10**.

| LVO | target | function |
|-----|--------|----------|
| -6  | 0x254  | LibOpen — open count +1, clear DELEXP, return libbase |
| -12 | 0x262  | LibClose — count -1; last close + DELEXP -> expunge |
| -18 | 0x276  | LibExpunge |
| -24 | 0x2bc  | `moveq #0,d0; rts` |
| -30 | 0x2cc  | XpksPackerInfo — returns lib+0x26 |
| -36 | 0x2d6  | XpksPackChunk — wrapper@0x300 -> core@0x36e |
| -42 | 0x2e2  | `rts` |
| -48 | 0x2e4  | `rts` |
| -54 | 0x2e6  | XpksUnpackChunk — wrapper -> decoder@0x696 |
| -60 | 0x2f4  | `rts` |

ABI: xsp in a0 for pack/unpack wrappers, libbase in a6 for lifecycle.
See `libraries/xpkSQSH_1.00.library/okf/functions/vectors.md` for the
full routine descriptions — the code is byte-identical.
