# xpkSQSH 1.00 — vector map

AUTOINIT, **absolute-longword** functab at 0x58 (10 entries + -1
terminator). InitTable@0x48: dataSize 0xa8, datatab@0x84, init@0xa4.
Hunk-relative targets in the original:

| LVO | target | function |
|-----|--------|----------|
| -6  | 0x254  | Open — `addqw #1,a6@(32); bclr #3,a6@(14); moveal a6,d0; rts` |
| -12 | 0x262  | Close — `moveq #0,d0; subqw #1,a6@(32)`; last close + DELEXP -> bsr 0x276 |
| -18 | 0x276  | Expunge — OpenCnt!=0 -> set DELEXP + return 0; else nop-stub call, Remove, FreeMem(negsize+possize), return seglist@+34 |
| -24 | 0x2bc  | `moveq #0,d0; rts` |
| -30 | 0x2cc  | XpksPackerInfo — `movel a6,d0; addil #38,d0; rts` (lib+0x26) |
| -36 | 0x2d6  | XpksPackChunk — moveml + bsr 0x300 (pack wrapper -> core @0x36e) |
| -42 | 0x2e2  | `rts` |
| -48 | 0x2e4  | `rts` |
| -54 | 0x2e6  | XpksUnpackChunk — moveml + bsr 0x696 (decoder) |
| -60 | 0x2f4  | `rts` |

LibInit @0xa4 (init-table tail): `moveml d0-a6` … stores a0(seglist)
at lib+34, then builds the XpkMode block at lib+0x7e and the XpkInfo
block at lib+0x26 in code (no static datatab for the descriptor), and
zeroes the tail of private data (dataSize 0xa8 total). No CPU gate.

Entry stub @0: `moveq #0,d0; rts`.

Also present: a do-nothing routine at 0x2c0 (`moveml; nop; moveml;
rts`) called from LibExpunge — apparently a leftover patch hook; the
reconstruction omits it.

XPK ABI: Pack/Unpack wrappers receive `xsp` in **a0** (not on the
stack); lifecycle vectors receive libbase in **a6**. The C
reconstruction declares `REGPARM_A0`/`REGPARM_A6` accordingly.
