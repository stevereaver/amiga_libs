# Functions

| LVO | Symbol | Role |
|-----|--------|------|
| -6  | Open | opencnt++, clear DELEXP, return libbase |
| -12 | Close | opencnt--; falls through into expunge on last close |
| -18 | Expunge | deferred (DELEXP) or Remove+FreeMem, returns seglist |
| -24 | — | reserved -> hunk+0 entry stub (`moveq #0,d0; rts`) |
| -30 | XpksPackerInfo | returns &XpkInfo (static island, hunk+0x1f6) |
| -36 | XpksPackChunk | ByteRun0 encoder (see below) |
| -42 | XpksPackFree | stub -> hunk+0 |
| -48 | XpksPackReset | stub -> hunk+0 |
| -54 | XpksUnpackChunk | ByteRun1 decoder |
| -60 | XpksUnpackFree | stub -> hunk+0 |

- [XpksPackChunk.md](XpksPackChunk.md)
- [XpksUnpackChunk.md](XpksUnpackChunk.md)
