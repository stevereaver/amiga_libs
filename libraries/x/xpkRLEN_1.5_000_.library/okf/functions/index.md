# Functions

Word-offset functab at hunk+0x98 (offsets relative to table start).
LVO map, vectors -6 .. -60:

| LVO | Symbol | Target | Role |
|-----|--------|--------|------|
| -6  | LibOpen | hunk+0xb8 | OpenCnt++, clear DELEXP, return a6 |
| -12 | LibClose | hunk+0xc6 | OpenCnt--, pending-expunge check, `bne.w`/`beq.w` to the hunk-0 stub |
| -18 | LibExpunge | hunk+0xd8 | deferred (bset + `bra.w` stub) or real Remove/FreeMem via a5/saved d2 |
| -24 | (reserved) | hunk+0x00 | dead slot -> entry stub `moveq #0,rts` |
| -30 | XpksPackerInfo | hunk+0x116 | `lea pc@(0xe6)` -> XpkInfo island at 0x1fe |
| -36 | XpksPackChunk | hunk+0x11e | dbra-scan PackBits encoder |
| -42 | XpksPackFree | hunk+0x00 | dead slot -> entry stub |
| -48 | XpksPackReset | hunk+0x00 | dead slot -> entry stub |
| -54 | XpksUnpackChunk | hunk+0x1d8 | PackBits decoder |
| -60 | XpksUnpackFree | hunk+0x00 | dead slot -> entry stub |

- [XpksPackChunk.md](XpksPackChunk.md)
- [XpksUnpackChunk.md](XpksUnpackChunk.md)
