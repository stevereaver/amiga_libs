# mhimpegit.library 4.0 — defects & quirks (all reproduced)

1. **Append never checks AllocVec** — a NULL node is written to
   unconditionally (`movel d3,a2@(8)` etc.), so OOM corrupts low memory.
2. **Create leaks prelude on repeat** — it calls OpenLibrary and stores
   BSS+12 unconditionally on every call; a second Create without an
   intervening Destroy loses the previous base. Also: on feature-gate or
   alloc failure, Create stores BSS+12=result BEFORE checking — a failed
   OpenLibrary leaves BSS+12=0 as expected, but a failed gate still runs
   the full teardown helper on a NULL obj, closing the just-opened lib.
3. **Iterate reads out of bounds** — the walk starts on the 12-byte list
   header block as if it were a node: `a2+12`/`a2+16` fall 4 bytes past
   the allocation. Whether the header produces a spurious prelude@-60
   call depends on neighbour heap bytes (observed both ways).
4. **Query returns garbage** — `move.l a3,d0; seq d0; neg.b d0` leaves
   the object pointer's upper 24 bits in the result; only the low byte
   is meaningful.
5. **Append's NULL-obj return** — `clr.w d0` on the caller's d1 copy
   leaves `(arg1 & 0xffff0000)`, not a clean 0.
6. **Stale d1 to prelude@-60** — `move.w #4104,d1` keeps the caller's
   high word; prelude sees `0x????1008`.
7. **Drain passes stale registers** — `move.w #128,d0` keeps stale high
   bits; a0/d1/d2 for prelude@-84/-36 are leftovers.
8. **-72 is a bare rts** — returns whatever d0 the caller had.
9. **-24 and -72 stubs** — both LVOs are dummies.
10. **68020+ required** — BSR.L, memory-indirect EA, divu.l; crashes a
    68000.
11. **DATA hunk InitTable** — rt_Init is a data-hunk relocation; the
    inittab itself sits in the DATA hunk (unusual but valid AUTOINIT).
12. **Dead $DFF000 constants** — data+0 and data+0x50 hold `0x00dff000`
    (custom-chip base) that nothing references.
13. **Feature gate is prelude-version-specific** — Create tests bit0 of
    `*(prelude+0x38)+0x15`; if prelude's internal layout differs the lib
    silently fails (closes prelude, returns 0).
