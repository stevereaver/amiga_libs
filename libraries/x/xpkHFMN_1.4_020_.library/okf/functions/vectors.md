# xpkHFMN 1.4 — vector map

AUTOINIT, word-offset functab (leading -1 marker, signed word offsets
from the table base).  Hunk-relative targets in the original:

| LVO | target | function |
|-----|--------|----------|
| -6  | 0xc0   | Open — OpenCnt++, clear DELEXP, return base |
| -12 | 0xce   | Close — OpenCnt--; last close + DELEXP -> expunge |
| -18 | 0xe0   | Expunge — DELEXP if open; else Remove+FreeMem(negsize..possize), return seglist@+34 |
| -24 | 0x000  | offset -0x92 lands on entry stub `moveq #0,d0;rts` |
| -30 | 0x186  | XpksPackerInfo — returns &xpkinfo (LEA pc; move.l a0,d0) |
| -36 | 0x18e  | XpksPackChunk — a0=xsp; pack |
| -42 | 0x11e  | XpksPackFree — FreeMem(Sub[0]-4, *Sub[0]-4) |
| -48 | 0x136  | XpksPackReset — wipes Sub[0]+0..0x1a09 (10+32*208=6666B) |
| -54 | 0x418  | XpksUnpackChunk — a0=xsp; unpack |
| -60 | 0x11e  | XpksUnpackFree — same routine as -42 |

Entry stub @0: `moveq #0,d0;rts` — doubles as LibInit failure return
(beq from LibInit on non-020) and the -24 vector target.
