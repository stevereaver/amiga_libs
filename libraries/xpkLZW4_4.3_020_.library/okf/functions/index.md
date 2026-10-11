# functions

| LVO | Name | Notes |
|-----|------|-------|
| -6 | LibOpen | OpenCnt++, clear LIBF_DELEXP |
| -12 | LibClose | OpenCnt--; if 0 and DELEXP -> Expunge |
| -18 | LibExpunge | OpenCnt!=0 -> set DELEXP, ret 0; else Remove + FreeMem(neg+pos), ret seglist |
| -24 | LibNull | `moveq #0,rts` |
| -30 | XpksPackerInfo | return s_xpkinfo descriptor in d0 |
| -36 | XpksPackChunk | lazy-matching hash-chain LZ encoder |
| -42 | XpksPackFree | FreeMem(xsp_Sub[0]-4, buf[0]) |
| -48 | XpksPackReset | zero exactly head[65536] (256 KB) |
| -54 | XpksUnpackChunk | flag-long stream decoder; no outlen writeback |
| -60 | LibNull | `moveq #0,rts` |

## XpkSubParams fields used
- pack: xsp[0]=inbuf, xsp[4]=inlen, xsp[8]=outbuf (bound =
  outbuf+inlen; xsp[12] outbuflen ignored), xsp[16]=outlen written,
  xsp[28]=mode -> lazy budget, xsp[52]=xsp_Sub[0] workmem pointer
- unpack: xsp[0]=inbuf, xsp[8]=outbuf; runs to the zero token
- PackFree/PackReset use xsp[52] only; Reset tolerates NULL

## Error codes
- -7  AllocMem(0x80004) failed
- -17 output hit outbuf+inlen bound (incompressible input)
