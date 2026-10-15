---
type: Finding
title: xpkILZR 1.2 quirks & defects
---

# Quirks & defects

## 1. PackFree leaks both workmem blocks

`XpksPackFree` only `clr.l`s `xsp_Sub[0..1]` — the two
sub-allocated blocks (head 0x10000, chain 0x8024 + 20-byte
headers) are never freed.  The freelist head at base+0x110
still links them, but nothing ever reuses or frees the
chain → ~96KB leaked per pack session on the master copy.
Reproduced in the C (`XpksPackFree` drops the pointers).

## 2. chain[] is never cleared — garbage links

`AllocMem` (flags 0) returns uninitialised memory; only
`head[]` is wiped per pack (PackChunk does a full 64KB
clear EVERY call, PackReset does the same).  `chain[]`
starts as heap garbage — a fresh pack walks stale links,
filtered only by `prev >= cand` monotonicity and the
18-failure budget.  Garbage links can still reach the
precheck and source matches that never existed (position-
independent corruption is unlikely but possible).
Reproduced faithfully.

## 3. Dead Open fixup — xi_ModeDesc left as offset 0x38

Open contains a relocation loop (LAB_0024) that was meant
to walk an offset list at `master+0x2e` and rebase copied
descriptor fields by `copy+0x3c`.  `LibInit` sets
`master+0x2e = 0`, so the loop never runs — `xi_ModeDesc`
in every copy stays `0x38` (a block-relative offset, not a
pointer).  Anything dereferencing it reads block+0x38 —
which HAPPENS to be the mode record, but as an absolute
address 0x38 it's invalid.  Reproduced as-is.

## 4. Open-count drift across copies

Open bumps the count on the CALLED base; Close on a copy
frees the copy but decrements the MASTER.  Opening
through a copy (A=open(master)→copy, B=open(copy)→copy2)
increments copy's count that is never decremented —
master's count drifts negative on close.  Shipped.

## 5. Decoder production has no bound

After the one-time header check (-10), the copy loop is
unbounded — a trailing match may overrun the declared
length (and past the caller's buffer).  Also reads the
stream 4 bytes at a time — up to 3 bytes of over-read on
the last field.

## 6. chain[] OOB past 0x4012 positions

`chain[pos]` (word index, long addressing) writes past the
0x8024 block for `pos > 0x4011` — InLen > ~16.4KB scribbles
the following heap.  `MaxPkInChunk = 0x4000` is the only
contractual guard.  (Also `head[]`/`chain[]` walks use
`.w` index extension — positions ≥ 0x4000 would sign-
extend negative on the reads.)

## 7. Input-boundary OOB reads

Hash seed reads `in[1]`/`in[2]` for runcap>1 (OOB at
InLen ≤ 2); precheck and cmpm reads run ~19 bytes past
the last position; `in[cur+best]` refresh can touch
in+18+18.  Reads only — packed output unaffected.

## 8. UnpackFree returns garbage

-60 vector is a bare `rts` — whatever's in d0 is the
return value (typically leftover from the call).

## 9. Version/idstring inconsistencies

File named 1.2, `rt_IdString` = "xpkILZR v1.3",
`lib_Version/Revision` = 1.2, `$VER` in the copied block
= "xpkIZLR.library 1.2" (transposed letters), and
`xi_DefMode` = 50 vs the mode record's `upto = 100`.
