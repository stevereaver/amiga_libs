# xpkFAST 1.06 — vector table

LONG-absolute-entry functab (10 `dc.l` entries + `dc.l -1`
terminator) at code+0x68; hunk relocs make each entry an
absolute code address.  No `-1` word marker.

| LVO  | functab idx | target (orig) | function            |
|------|-------------|---------------|---------------------|
| -6   | 0           | 0x0c4         | LibOpen             |
| -12  | 1           | 0x0d2         | LibClose            |
| -18  | 2           | 0x0e2         | LibExpunge          |
| -24  | 3           | 0x120         | ExtFunc stub        |
| -30  | 4           | 0x1d2         | XpksPackerInfo      |
| -36  | 5           | 0x124         | XpksPackChunk       |
| -42  | 6           | 0x196         | XpksPackFree        |
| -48  | 7           | 0x1b8         | XpksPackReset stub  |
| -54  | 8           | 0x1bc         | XpksUnpackChunk     |
| -60  | 9           | 0x1b8         | UnpackReset stub    |

All three stubs (`-24`, `-48`, `-60`) are `moveq #0,d0;rts` —
both Reset vectors are NO-OPs in 1.06 (1.2's PackReset actually
zeroes the hash tables; 1.06 does not).

## Entry points

- `LibInit` (code+0xb4, reached via initstruct.initfunc):
  stores a6 -> lib+34 (execbase), a0 -> lib+38 (seglist),
  returns.  dataSize 0x4a.
- `LibOpen` — `++OpenCnt` at lib+0x20, clear LIBF_DELEXP,
  return base.
- `LibClose` — `--OpenCnt`; on 0 with DELEXP set: expunge
  (Remove + FreeMem), return seglist.
- `LibExpunge` — OpenCnt>0 -> set DELEXP, return 0; else
  expunge now, return seglist.
- `XpksPackerInfo(a0=xsp)` — returns `_xpkinfo` in d0
  (descriptor base).  Does NOT touch xsp.
- `XpksPackChunk(a0=xsp)` — mode < 80 unsigned -> speedy
  (0x10000 workmem), else crawling (0x44000).  Workmem at
  `xsp->xsp_Sub[0]`, its size at `xsp->xsp_Sub[1]`; reallocates
  via the PackFree body when the size differs.  Returns -7 on
  AllocMem failure, -17 when the packer returns 0 (stream
  collision), else 0 with `xsp->xsp_OutLen` set.
- `XpksPackFree(a0=xsp)` — FreeMem(Sub[0], Sub[1]); clears both.
- `XpksUnpackChunk(a0=xsp)` — decodes the stream, returns 0.
  Uses `xsp_InBuf/xsp_InLen` (backward ctrl walk from the end)
  and `xsp_OutBuf`; never touches `xsp_OutBufLen`.

## Original code-hunk map

```
0x000 EndSkip stub (moveq #-1,d0;rts)
0x004 RomTag (rt_Init -> initstruct at 0x58, AUTOINIT)
0x01e "xpkFAST.library" / 0x02e "$VER:..."
0x058 initstruct {dataSize 0x4a, functab 0x68, datatab 0x94,
      initfunc 0xb4}
0x068 functab (10 longs + -1)
0x094 datatab (nonstandard -- see structures/layout.md)
0x0b4 LibInit
0x0c4..0x1db lifecycle + dispatch + stubs
0x1dc XpkInfo descriptor + strings + mode chain (..0x318)
0x314 speedy packer .. 0x534
0x534 crawling packer .. 0x6f4
0x6f4 unpacker .. 0x7a6 (code hunk end 0x7a8)
```
