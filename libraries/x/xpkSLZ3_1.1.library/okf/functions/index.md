# functions

| LVO | Name | Notes |
|-----|------|-------|
| -6 | LibOpen | OpenCnt++, clear LIBF_DELEXP (lib_Flags @14 bit3) |
| -12 | LibClose | OpenCnt--; if 0 and DELEXP -> Expunge |
| -18 | LibExpunge | OpenCnt!=0 -> set DELEXP, ret 0; else Remove + FreeMem(neg+pos), ret seglist.  Reads stack top twice (a0=a1=[sp]) before popping |
| -24 | LibNull | `moveq #0,rts` |
| -30 | XpksPackerInfo | `lea` descriptor, return in d0 |
| -36 | XpksPackChunk | LZ77 encoder, own 256 KB ctx table |
| -42 | LibNull | XpksPackFree (null -- workmem freed inline) |
| -48 | LibNull | XpksPackReset (null) |
| -54 | XpksUnpackChunk | flag-grouped decoder; no outlen writeback |
| -60 | LibNull | XpksUnpackFree (null) |

## XpkSubParams fields used
- pack: xsp[0]=inbuf, xsp[4]=inlen (used as `inlen-1` last index),
  xsp[8]=outbuf, xsp[16]=outlen (written)
- unpack: xsp[0]=inbuf, xsp[8]=outbuf; terminates on zero token;
  xsp_OutLen NOT written
