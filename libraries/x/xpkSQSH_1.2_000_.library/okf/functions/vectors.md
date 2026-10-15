---
type: Function
title: vector map
---

# xpkSQSH 1.2 (000) — vector map

AUTOINIT, word-offset functab (leading -1 marker, signed word offsets
from the table base, -1 terminator). Hunk-relative targets in the
original:

| LVO | target | function |
|-----|--------|----------|
| -6  | 0x0ae  | Open — OpenCnt++, clear DELEXP, return base |
| -12 | 0x0bc  | Close — OpenCnt--; last close + DELEXP -> expunge |
| -18 | 0x0ce  | Expunge — unlink node + FreeMem, return seglist@+34 |
| -24 | 0x000  | entry stub — `moveq #0,d0;rts` |
| -30 | 0x10c  | XpksPackerInfo — returns descriptor pointer |
| -36 | 0x130  | XpksPackChunk — a0=xsp; pack |
| -42 | 0x114  | XpksPackFree — FreeMem(Sub[0], 0x22080) if set |
| -48 | 0x000  | entry stub (reserved) |
| -54 | 0x57e  | XpksUnpackChunk — a0=xsp; unpack |
| -60 | 0x000  | entry stub (reserved) |

LibInit: stores seglist at lib+34 and returns — **no CPU gate**
(unlike the 020 twin, which tests `AttnFlags` bit 1 for AFF_68020).

Differences vs the 020 build's vector map: -42/-54/-60 layout — on
the 020, -60 pointed at the same routine as -42 (PackFree); here it
is the shared entry stub, matching -24/-48. The reconstruction's
generated functab reproduces this map.

Entry points take `xsp` in `a0` (XPK sublibrary ABI) — the
reconstruction annotates the parameters `__asm("a0")`; the earlier
020 reconstruction read them from the stack and only worked by host
accident.
