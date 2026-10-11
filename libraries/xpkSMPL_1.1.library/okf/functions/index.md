# functions / vectors

| LVO | name | notes |
|-----|------|-------|
| -6  | LibOpen | OpenCnt++, returns libbase |
| -12 | LibClose | OpenCnt--, expunge on last close if DELEXP |
| -18 | LibExpunge | Remove + FreeMem(base,0x26) |
| -24 | LibNull | reserved |
| -30 | XpksPackerInfo | returns &_xpkinfo |
| -36 | XpksPackChunk | workmem then pack_body; -17 short inlen, -7 alloc fail |
| -42 | XpksPackFree | FreeVec(xsp_Sub[0]) |
| -48 | LibNull | PackReset slot (inert) |
| -54 | XpksUnpackChunk | workmem then unpack_body; -26 bad sig |
| -60 | XpksPackFree | same as -42 |

internal helpers: emit_inline (subq.b/rol16/movew/add.b/clrw/
lsll/orl sequence), emit_code (0x3ec, len>=16 split), getbits/
refill (lsrl + rol16/movew), trie walk.
