---
type: Function
title: LibOpen
description: Open writes FPCR=0x90, bumps OpenCnt, clears private DELEXP bit.
lvo: -6
registers: a6 base -> d0 base
timestamp: 2026-10-10T23:00:00Z
---

# ``struct Library *LibOpen(void)``

**LVO -6**

```asm
moveq   #72,d0
add.l   d0,d0           ; d0 = 0x90
fmove.l d0,fpcr         ; FPCR = double precision, round-toward-zero
addq.w  #1,0x20(a6)     ; OpenCnt++
bclr    #3,0x2a(a6)     ; clear private DELEXP bit
move.l  a6,d0
rts
```

Unlike the singtrans/mathtrans siblings, Open **programs the
FPCR** to 0x90 (double-precision results, round-to-zero) on
every call — this is what makes the `fmove.l fp0,d0` in
IEEEDPFix truncate for callers that went through Open (see
[FixRounding](../findings/FixRounding.md)).  The DELEXP clear
targets the private byte at base+0x2a, not `lib_Flags` (see
[Quirks](../findings/Quirks.md)).
