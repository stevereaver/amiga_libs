# Functions

| LVO | Symbol | Role |
|-----|--------|------|
| -6  | Open | opencnt++, clear DELEXP, return libbase |
| -12 | Close | opencnt--; fall into expunge on last close |
| -18 | Expunge | deferred (DELEXP) or Remove+FreeMem, returns seglist |
| -24 | — | reserved stub: `moveq #0,d0; rts` |
| -30 | XpksPackerInfo | returns &XpkInfo (static island, hunk+0x164) |
| -36 | XpksPackChunk | stub: `movel #-1,d0; rts` -> -1 |
| -42 | XpksPackFree | stub -> -1 (same code) |
| -48 | XpksPackReset | stub -> -1 (same code) |
| -54 | XpksUnpackChunk | stub -> -1 (same code) |
| -60 | XpksUnpackFree | stub -> -1 (same code) |

All five packer slots (hunk+0x15c) are ONE shared `movel #-1,d0; rts`
— this sublibrary ships descriptors only, no codec.

- [XpksPackChunk.md](XpksPackChunk.md)
- [XpksUnpackChunk.md](XpksUnpackChunk.md)
