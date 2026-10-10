---
type: Function
title: XpksPackChunk
description: RLE encoder — literal and repeat runs, expansion-bounded.
lvo: -36
timestamp: 2026-10-10T09:40:00Z
---

# Signature

```c
LONG XpksPackChunk(struct XpkSubParams *xsp /* a0 */,
                   struct XpkSubBase *base /* a6 */);  /* -> d0 */
```

# Semantics

Register map after `movem.l d2-d6/a2-a6` + argument fetch: a1=src,
a4=lit (pending literal start), a5=out, a3=srcend=InBuf+InLen,
a6=outlim=OutBuf+OutBufLen, d2=runlen, d6=pend (src-lit).

Main loop (.text+0x170):

1. `runlen = (src[0]==src[1] && src[1]==src[2]) ? 2 : 0` — samples
   src[1] and src[2] unconditionally, so the last two input bytes are
   read *past the buffer end* (see [ReadPastEnd](../findings/ReadPastEnd.md)).
2. If `out + 4 + pend > outlim` → return `XPKERR_EXPANSION` (-17).
   The check reserves 4 bytes overhead although a literal flush only
   writes `1 + pend` (see [LiteralReserve4](../findings/LiteralReserve4.md)).
3. `runlen==0` and `pend<0x7f` and `src!=srcend` → `src++`, loop
   (extend pending literal, cap 127).
4. `pend>0` → emit `pend` as the literal code then `pend` bytes.
5. `src==srcend` → break.
6. `lit = src`; `runlen==0` → `src++`, loop.
7. Else extend the repeat run: `runlen++` while `src+runlen < srcend`
   and `probe[0]==probe[-1]` and `runlen<0x7f`; emit `-runlen` then
   `src[0]`; `src = lit += runlen`.

Epilogue: emit `0x00` terminator, `xsp_OutLen = out - OutBuf`,
return `XPKERR_OK`. .text+0x160.
