---
type: Function
title: CheckSemaphore (hidden)
description: Base-exported helper that XOR-decodes a semaphore name and calls exec FindSemaphore. Not reachable via the jump table.
lvo: -
registers: d0 in (XOR key), d0 out (SignalSemaphore* or NULL)
---

# `struct SignalSemaphore *CheckSemaphore(ULONG key /* d0 */)`

**Not an LVO.**  `LibInit` stores its address at base+0x32
(`vb_Check`); nothing inside the library calls it.  External code
that knows the private base layout invokes it with a key byte.

Disassembly (text+0xd4):

```
movem.l d2/a2/a6,-(sp)
movea.l 4.w,a6          ; SysBase from AbsExecBase (not base+0x22)
move.l  d0,d2           ; d2 = key
lea     data(pc),a2     ; -> text+0x102, 10 obfuscated bytes
movea.l a2,a0
moveq   #9,d1
xor1:   eor.b d2,(a0)+  ; deobfuscate
dbf     d1,xor1
movea.l a2,a1           ; a1 = semaphore name
jsr     -594(a6)        ; exec FindSemaphore
movea.l a2,a0
moveq   #9,d1
xor2:   eor.b d2,(a0)+  ; re-obfuscate
dbf     d1,xor2
movem.l (sp)+,d2/a2/a6
rts
data:   42 c9 a0 b9 9b 8c 8f 9a c9 52   ; ^ key -> name\0
```

- The name buffer lives in the code hunk and is NUL-terminated by
  the trailing pad byte.
- With key **0xE9** the bytes decode to `« IPrefs »` (0xAB/0xBB are
  the Amiga-1251 guillemets) — see
  [HiddenSemaphoreCheck](../findings/HiddenSemaphoreCheck.md).
- Because the key is a *parameter*, other decodings are possible;
  no caller is present in this binary.
