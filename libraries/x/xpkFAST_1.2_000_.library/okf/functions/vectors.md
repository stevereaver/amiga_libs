# xpkFAST 1.2 — vector table

Word-offset functab (`dc.w -1` marker + 10 `dc.w` entries,
offsets relative to the table start).  Original table at
code+0x98.

| LVO  | offset | target (orig) | function          |
|------|--------|---------------|-------------------|
| -6   | +0x20  | 0x0b8         | LibOpen           |
| -12  | +0x2e  | 0x0c6         | LibClose          |
| -18  | +0x40  | 0x0d8         | LibExpunge        |
| -24  | -0x98  | 0x000         | LibNull (stub)    |
| -30  | +0xf8  | 0x190         | XpksPackerInfo    |
| -36  | +0x100 | 0x198         | XpksPackChunk     |
| -42  | +0x7e  | 0x116         | XpksPackFree      |
| -48  | +0x96  | 0x12e         | XpksPackReset     |
| -54  | +0x426 | 0x4be         | XpksUnpackChunk   |
| -60  | -0x98  | 0x000         | LibNull (stub)    |

## Entry points

- `LibInit` — stores the seglist pointer at lib offset 34,
  returns d0=lib.  Called by exec `InitResident`.
- `LibOpen`/`LibClose`/`LibExpunge` — standard; the -24 vector
  wraps to the `moveq #0,d0;rts` stub at code+0 (returns NULL).
- `XpksPackerInfo(a0=xsp)` — stores `_xpkinfo` at
  `xsp->xsp_Sub[0]` (xsp+0x34).
- `XpksPackChunk(a0=xsp)` — first call allocates workmem
  (0x10004 speedy / 0x44004 crawling, size stored in slot -1),
  clears tables, then packs.  Mode select:
  `xsp->xsp_Mode < 79` unsigned → speedy (flag 0), else
  crawling (flag 3).  Returns -17 on output overrun, -7 on
  AllocMem failure, else 0 with `xsp->xsp_OutLen` set.
- `XpksPackFree(a0=xsp)` — frees `xsp->xsp_Sub[0]-1` sized
  `*(Sub[0]-1)`; clears Sub[0].
- `XpksPackReset(a0=xsp)` — zero-fills `(Sub[1]+1)*0x10000`
  bytes from `Sub[0]` when Sub[0] set (i.e. 64 KB speedy table
  or 256 KB of the crawling hash table; the crawling *chain*
  table at Sub[0]+0x40000 is NOT cleared — see defects).
- `XpksUnpackChunk(a0=xsp)` — decodes the stream, returns 0.
  Uses `xsp_InBuf/xsp_InLen` (backward tail walk) and
  `xsp_OutBuf`; never touches `xsp_OutBufLen`.
