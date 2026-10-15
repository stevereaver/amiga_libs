# Functions

| LVO | Symbol | Role |
|-----|--------|------|
| -6  | LibOpen | OpenCnt++, clear DELEXP |
| -12 | LibClose | OpenCnt--, deferred expunge |
| -18 | LibExpunge | Remove + FreeMem |
| -24 | LibEntry | bra to module start |
| -30 | XpksPackerInfo | returns base+0xe0 (copied XpkInfo) |
| -36 | XpksPackChunk | PackBits encoder |
| -42 | XpksPackFree | stub |
| -48 | XpksPackReset | returns 0 |
| -54 | XpksUnpackChunk | decoder |
| -60 | XpksUnpackFree | stub |

- [XpksPackChunk.md](XpksPackChunk.md)
- [XpksUnpackChunk.md](XpksUnpackChunk.md)
- [InitFunction.md](InitFunction.md)
