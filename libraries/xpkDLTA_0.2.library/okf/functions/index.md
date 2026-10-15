# Functions

| LVO | Vector | Target | Role |
|----:|--------|--------|------|
| -6  | LibOpen | 0x17a | OpenCnt++, clear DELEXP, return base |
| -12 | LibClose | 0x188 | OpenCnt--, falls into Expunge on DELEXP |
| -18 | LibExpunge | 0x196 | deferred while open; Remove+FreeMem, returns seglist |
| -24 | (reserved) | 0x20a | shared null → 0 |
| -30 | XpksPackerInfo | 0x216 | returns embedded XpkInfo (base+0x26) |
| -36 | XpksPackChunk | 0x1ce | byte-delta encode |
| -42 | XpksPackFree | 0x20a | shared null → 0 |
| -48 | XpksPackReset | 0x20a | shared null → 0 |
| -54 | XpksUnpackChunk | 0x21e | byte-delta decode |
| -60 | XpksUnpackFree | 0x20a | shared null → 0 |

- [LibVectors.md](LibVectors.md)
- [XpksPackerInfo.md](XpksPackerInfo.md)
- [XpksPackChunk.md](XpksPackChunk.md)
- [XpksUnpackChunk.md](XpksUnpackChunk.md)
