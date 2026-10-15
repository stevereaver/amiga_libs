# Functions

| LVO | Vector | Target | Role |
|----:|--------|--------|------|
| -6  | LibOpen | 0xb4 | OpenCnt++, clear DELEXP, return base |
| -12 | LibClose | 0xc2 | OpenCnt--, falls into Expunge on DELEXP |
| -18 | LibExpunge | 0xd4 | deferred while open; Remove+FreeMem, returns seglist |
| -24 | (reserved) | 0x00 | stub → 0 |
| -30 | XpksPackerInfo | 0x112 | returns XpkInfo island (code+0x15a) |
| -36 | XpksPackChunk | 0x11a | byte-delta encode |
| -42 | XpksPackFree | 0x00 | stub → 0 |
| -48 | XpksPackReset | 0x00 | stub → 0 |
| -54 | XpksUnpackChunk | 0x140 | byte-delta decode |
| -60 | XpksUnpackFree | 0x00 | stub → 0 |

- [LibVectors.md](LibVectors.md)
- [XpksPackerInfo.md](XpksPackerInfo.md)
- [XpksPackChunk.md](XpksPackChunk.md)
- [XpksUnpackChunk.md](XpksUnpackChunk.md)
