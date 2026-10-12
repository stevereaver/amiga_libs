# xpkHFMN 1.4 (000) — vector map

AUTOINIT, word-offset functab at hunk+0x92 (leading -1 marker, signed
word offsets from the table base, -1 terminator).  Hunk-relative
targets in the original:

| LVO | entry | target | function |
|-----|-------|--------|----------|
| -6  | 0x0020 | 0x0b2 | Open — OpenCnt++, clear DELEXP, return base |
| -12 | 0x002e | 0x0c0 | Close — OpenCnt--; last close + DELEXP -> expunge |
| -18 | 0x0040 | 0x0d2 | Expunge — DELEXP if open; else unlink node + FreeMem(negsize..possize), return seglist@+34 |
| -24 | 0xff6e | 0x000 | offset -0x92 lands on entry stub `moveq #0,d0;rts` |
| -30 | 0x00e6 | 0x178 | XpksPackerInfo — returns &xpkinfo |
| -36 | 0x00ee | 0x180 | XpksPackChunk — a0=xsp; pack |
| -42 | 0x007e | 0x110 | XpksPackFree — FreeMem(Sub[0]-4, *Sub[0]-4) |
| -48 | 0x0096 | 0x128 | XpksPackReset — wipes Sub[0]+0..0x1a09 |
| -54 | 0x0430 | 0x4c2 | XpksUnpackChunk — a0=xsp; unpack |
| -60 | 0x007e | 0x110 | XpksUnpackFree — same routine as -42 |

LibInit @0xaa: `movea.l d0,a1; move.l a0,0x22(a1); rts` — stores the
seglist and returns; unlike the 020 build there is no AttnFlags check.

Entry stub @0: `moveq #0,d0;rts` — the -24 vector target via a
negative functab offset (in the 020 build it also served as the
init-fail return; here it is vestigial).
