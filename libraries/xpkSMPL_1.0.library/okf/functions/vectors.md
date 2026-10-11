# Vectors (AUTOINIT word-offset functab)

| LVO | target | name | notes |
|-----|--------|------|-------|
| -6  | LibOpen        | open | ++OpenCnt, clear DELEXP |
| -12 | LibClose       | close | --OpenCnt, expunge on DELEXP |
| -18 | LibExpunge     | expunge | Remove+FreeMem, DELEXP if open |
| -24 | stub           | moveq #0,d0;rts | dedicated stub |
| -30 | XpksPackerInfo | info | returns the static descriptor |
| -36 | XpksPackChunk  | pack | allocs pack wk 0x3710 on first call |
| -42 | XpksPackFree   | free | frees Sub[0], clears it (1.0-specific) |
| -48 | stub           | bare rts | dedicated no-op |
| -54 | XpksUnpackChunk| unpack | allocs unpack wk 0x1000 on first call |
| -60 | XpksPackFree   | free | same body as -42 |

XpkSubParams ABI identical to 1.1/1.2 (a0 params, a1 sublib base,
registers in `xsp_Sub[4]`; a6=base in all calls).
