# xpkFAST 1.10 — vector table

LONG-absolute-entry functab (10 `dc.l` entries + `dc.l -1`
terminator) at code+0x2e; hunk relocs make each entry an
absolute code address.

| LVO  | functab idx | target (orig) | function            |
|------|-------------|---------------|---------------------|
| -6   | 0           | 0x09e         | LibOpen             |
| -12  | 1           | 0x0ac         | LibClose            |
| -18  | 2           | 0x0c0         | LibExpunge          |
| -24  | 3           | 0x104         | ExtFunc stub        |
| -30  | 4           | 0x672         | XpksPackerInfo      |
| -36  | 5           | 0x5ce         | XpksPackChunk       |
| -42  | 6           | 0x63c         | XpksPackFree        |
| -48  | 7           | 0x134         | XpksPackReset stub  |
| -54  | 8           | 0x660         | XpksUnpackChunk     |
| -60  | 9           | 0x134         | UnpackReset stub    |

All three stubs (`-24`, `-48`, `-60`) are `moveq #0,d0;rts` —
Reset vectors are NO-OPs, same as 1.06.  -48/-60 share one stub
address (0x134, just past the idstr); -24 has its own copy at
0x104.

## Entry points

- `LibInit` (code+0x7e, via initstruct.initfunc):
  `a5=d0` (lib); stores a0 (seglist) at **code+0x7a** through an
  absolute.LONG store (`movel a0,0x7a` — the operand is hunk-
  relocated so it lands on the dead longword tail of the
  consumed datatab); `bsr` the return-0 stub (dead hook call,
  result ignored except a dead `bne` cleanup path); returns
  the lib in d0.
- `LibOpen` — `++OpenCnt` at lib+0x20, clear LIBF_DELEXP bit3
  at lib+14, return base.
- `LibClose` — `d0=0` first, `--OpenCnt`; on 0 with DELEXP set:
  bsr expunge body.
- `LibExpunge` — OpenCnt>0 -> set DELEXP, return 0; else
  `d2=segslot` (read PC-relative at code+0x7a), `Remove(lib)`,
  `bsr` the stub (dead hook), `FreeMem(lib-NegSize,
  NegSize+PosSize)`, return seglist.
- `XpksPackerInfo(a0=xsp)` — returns descriptor in d0 AND a0
  (`lea`+`movel a0,d0`; doesn't touch xsp).
- `XpksPackChunk(a0=xsp)` — `mode <= 80` (unsigned; boundary
  moved from 1.06's `< 80`) -> speedy (0x10000 workmem), else
  crawling (0x44000).  Workmem at `xsp->xsp_Sub[0]`, size at
  `xsp->xsp_Sub[1]`; a mismatched live workmem is released by
  `jsr a6@(-42)` — through the lib's own PackFree vector, so a
  SetFunction patch would be honored.  AllocMem size=d0,
  flags=1.  Packer call: `(a0=InBuf, a1=OutBuf, a2=workmem,
  d0=InLen, d1=90)` — d1 is a fixed vestigial arg.  Returns -7
  alloc fail, -17 packer returned 0 (stream collision), else
  OutLen written, 0.
- `XpksPackFree(a0=xsp)` — frees `xsp->xsp_Sub[0]` (size at
  Sub[1]) via exec FreeMem, clears both, returns 0.
- `XpksUnpackChunk(a0=xsp)` — `a1=xsp_OutBuf, d0=xsp_InLen,
  a0=xsp_InBuf`, calls the decoder; returns 0.  Unlike 1.06 the
  wrapper does NOT save/restore a1 (the decoder uses it as the
  output cursor).
