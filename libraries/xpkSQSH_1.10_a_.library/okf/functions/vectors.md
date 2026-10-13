# xpkSQSH 1.10(a) — vector map

AUTOINIT, absolute-longword functab (10 entries + -1), InitTable
dataSize 0xa8, datatab ln_Type=9/lib_Flags=6/version=1/revision=10.
Target offsets identical to 1.00:

| LVO | target | function |
|-----|--------|----------|
| -6  | 0x254  | LibOpen |
| -12 | 0x262  | LibClose |
| -18 | 0x276  | LibExpunge |
| -24 | 0x2bc  | `moveq #0,d0; rts` |
| -30 | 0x2cc  | XpksPackerInfo — lib+0x26 |
| -36 | 0x2d6  | XpksPackChunk — wrapper@0x2fc -> core@0x36a |
| -42 | 0x2e2  | `rts` |
| -48 | 0x2e4  | `rts` |
| -54 | 0x2e6  | XpksUnpackChunk — `bsrw 0x762` (decoder) |
| -60 | 0x2f4  | lands on data (dead stub, never called) |

Deltas vs 1.00 internals: pack wrapper at 0x2fc (4 bytes earlier),
encoder core at 0x36a, decoder at 0x762 (a hybrid that flows into the
btst bit-reader region ~0x888–0xb11). A 3-long data block at
0x2f2–0x2fb (`0000 / 0008 / 0000046a`) sits where 1.00 had the -60
rts stub.

ABI: xsp in a0 for pack/unpack wrappers, libbase in a6 for lifecycle —
same as 1.00.
