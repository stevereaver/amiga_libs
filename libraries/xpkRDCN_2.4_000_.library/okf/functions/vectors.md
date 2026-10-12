# xpkRDCN 2.4 — Vector Map

AUTOINIT, compact word-offset function table at file offset 0x94
(marker `ffff`, 10 entries, terminator `ffff`). Offsets are relative
to the functab itself (original values shown; reconstruction offsets
differ since the C image is larger).

| LVO | Orig off | Target | Function |
|-----|----------|--------|----------|
| -6  | 0x0020   | 0xb4   | LibOpen — `++OpenCnt; flags &= ~8; return base` |
| -12 | 0x002e   | 0xc2   | LibClose — `--OpenCnt; if 0 && DELEXP → expunge` |
| -18 | 0x0040   | 0xd4   | LibExpunge — OpenCnt? set DELEXP : remove+free |
| -24 | 0xff6c   | 0x00   | → hunk+0 `moveq #0,d0; rts` (EndSkip stub) |
| -30 | 0x00f2   | 0x186  | XpksPackerInfo — `lea info(pc),a0; return a0` |
| -36 | 0x00fa   | 0x18e  | XpksPackChunk — dispatcher (see below) |
| -42 | 0x007e   | 0x112  | XpksPackFree — `FreeMem(Sub[0]-4, *(Sub[0]-4))` if set |
| -48 | 0x0096   | 0x12a  | XpksPackReset — zero hash table(s) |
| -54 | 0x0470   | 0x504  | XpksUnpackChunk — token decoder |
| -60 | 0xff6c   | 0x00   | → hunk+0 stub (XpksUnpackFree no-op) |

## XpksPackChunk dispatcher (0x18e)

```
movem.l d2-d7/a0/a2-a6,-(sp)
a3 = a0 (xsp)
d0 = 79; cmp.l 28(a3),d0; bcc -> small   ; mode <= 79 (unsigned)
  big:   d3=15, d2=0x48004, a4=LAB_0028 (crawling packer)
  small: d3=0,  d2=0x4004,  a4=LAB_001C (speedy packer)
if (52(a3) == 0):
    a0 = AllocMem(d2, MEMF_ANY=0); if !a0 return -7
    *a0++ = d2                ; size prefix for PackFree
    52(a3) = a0               ; xsp_Sub[0] = workmem
    56(a3) = d3               ; xsp_Sub[1] = big flag (0 or 15)
a0 = a3; bsr PackReset; jmp (a4)
```

Note the threshold is `BCC` (unsigned `79 >= mode`): mode 0..79 →
speedy, mode 80+ → crawling. Matches the descriptor (`speedy`
xm_Upto=79, `crawling` xm_Upto=100).

## XpksPackReset (0x12a)

Clears `Sub[1] ? 0x40000 : 0x4000` bytes starting at `Sub[0]`,
implemented as a movem.l pre-decrement sweep walking downward from
`Sub[0]+size` (16 or 1 outer iterations of 0x4000 bytes via
`swap`-encoded loop counters). The crawling chain table at
`Sub[0]+0x40000` is never cleared — stale links persist across
resets, exactly like xpkFAST.

## LibInit (0xac)

`movea.l d0,a1; move.l a0,34(a1); rts` — stores the seglist at
base+34. dataSize = 0x26 (Library + 4).
