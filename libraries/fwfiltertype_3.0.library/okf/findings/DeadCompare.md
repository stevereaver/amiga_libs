---
type: Finding
title: Dual-use `cmpi.w` / `clr.l (a4)` in FwFilterType
timestamp: 2026-10-15T02:00:00Z
---

# `0c40 4294` is not (only) a dead compare

FwFilterType's store block ends:

```asm
    lea   _fwpen(pc),a0        ; *out = "fwpenpal.library"
    move.l a0,(a4)
    cmpi.w #$4294,d0           ; 0x1a4: dead compare on THIS path
; --- 0x1a6: mid-instruction entry from the miss path ---
    clr.l (a4)                 ; 0x4294 -> *out = NULL
```

The miss path `bne.b` at 0x19c targets 0x1a6 — inside the `cmpi.w`
operand — where the extension word `0x4294` executes as `clr.l (a4)`.
So the word serves two masters: a dead `cmpi.w` (flags unused) on the
store path and the `*out = 0` clear on the miss path.  Compiler
code-sharing trick; reproduced verbatim in `source/fwfiltertype.s`
with raw `.short` emits and a label at +2.
