---
type: Functions
title: xpkILZR 1.2 framework
---

# Framework — xpkILZR.library 1.2

## LibInit (code+0x1b2, initRoutine)

Manual init — `datatab == NULL` so `InitStruct` already
cleared the 0x114-byte base.  Sequence:

1. `a5 = d0` (base); `a0` → base+0x22 (seglist)
2. `ln_Type = 9`, `ln_Name = "xpkILZR.library"`,
   `lib_Flags = 6` (SUMUSED|CHANGED)
3. `lib_Version/lib_Revision = 1/2` (0x00010002 at +0x14)
4. `lib_IdString = "xpkILZR v1.3"` at +0x18
5. `base+0x2e = 0` — the fixup-offsets list, always NULL
6. `base+0x32 = base` — master back-pointer (self)
7. `base+0x36 = 0x3c` — copy bias constant
8. copy **192 bytes** code+0xea → base+0x3c (descblock:
   pad, "$VER: xpkIZLR…" string, mode record, XpkInfo,
   minsize tail)
9. return base in d0

## LibOpen — clone-per-open (code+0x206)

Not a refcount-only open: every call **copies the library**.

1. `open_cnt++`, `bclr #3, lib_Flags` (DELEXP)
2. `a0 = base+0x32` → master; AllocMem(`0x114 + master+0x36`
   = 0x150, MEMF_CLEAR|MEMF_PUBLIC); fail →
   `master->open_cnt--`, return 0
3. byte-copy `[base-0x3c, base+0xfc)` → new block
   (0x138 bytes: vectors + node + descriptor block + tail)
4. new base = alloc + 0x3c; `new+0x2e = 0`
5. dead fixup: walks `master+0x2e` list — always NULL, the
   loop at LAB_0024 never executes.  Entries were meant to
   rebase `new+0x3c`-relative offsets (e.g. xi_ModeDesc).
6. `CacheClearU` (the copied jump vectors are new code)
7. return the COPY — callers see a private library whose
   +0x32 still points at the master

## LibClose (code+0x29e)

- if `base+0x32 != base` (called through a copy):
  `FreeMem(copy-0x3c, 0x150)`, then decrement the MASTER's
  open count — `a5 = master` first
- if master count hits 0 and DELEXP → Expunge (returns
  seglist in d7)

Quirk: Open on a copy increments the COPY's count, but
closing the resulting grandchild decrements the MASTER —
count drift (shipped behaviour).

## LibExpunge (code+0x300)

- `a5 = base+0x32` — resolves to master whether called on
  master or copy
- `bset #3, lib_Flags` on master; if `open_cnt != 0` → 0
- else `d7 = master+0x22` (seglist), `Remove(node)`,
  `FreeMem(base - NegSize, NegSize + PosSize)`; returns seglist

## Null vectors

- -24: backward word offset (-0x2e) → entry stub
  `moveq #0,d0; rts` at code+0
- -60: `rts` at code+0x660 — d0 left undefined
