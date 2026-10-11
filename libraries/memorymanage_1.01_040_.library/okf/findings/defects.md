# Defects & inconsistencies — memorymanage.library 1.01

1. **Garbage SRP installed at attach.** Both profiles get
   `FreeVec(regionbuf)`'s *return value* patched into +4 (SRP) and
   +12 (DTT1).  FreeVec returns the freed byte count, not a pointer —
   the installed supervisor root pointer is a small integer, and DTT1
   = the same (harmless only because bit15=0 keeps the TTR disabled).
   The MMU is left translating through whatever page table the garbage
   SRP happens to hit.
2. **Detach restores the wrong thing.** The saved original register
   block (+50) captured by MMUReadRegs is never written back;
   MMUDetach instead writes profile B — the same patch-SRP block that
   attach installed — then frees all page tables.  After detach the
   MMU stays enabled pointing at freed/patched memory.
3. **Attach/detach profiles are byte-identical.** "prof_att" and
   "prof_det" start as the same 26 bytes and receive the same patch;
   maintaining two copies is dead weight.
4. **Return-value quirk.** MMUMap computes the leaf-table base in a2,
   but the final `movem (sp)+,...` restores every saved register and
   returns the *pushed entry d0* (the len argument).  MMUMapIdentity
   propagates it.  Callers must ignore the d0 result.
5. **refcnt leak on AllocVec failure.** If the 0x100 region buffer or
   the 0x410 root block fails, attach returns 0 leaving the bumped
   refcount (and, for the root failure, the region buffer) behind.
6. **Mixed memory-type mask.** The extent scan probes TypeOfMem with
   mask MEMF_FAST(4) but budgets against AvailMem(MEMF_KICK|MEMF_FAST)
   — extents of FAST-only regions are summed against a KICK|FAST total.
7. **TypeOfMem(0) probe.** next_extent starts scanning at a1=0 and
   adds 0x40000 before probing — first probed address is 0x40000; any
   FAST memory below 256KB is skipped silently.
8. **Partial tail page never mapped.** The page loop requires
   `len >= 0x1000` per store; a region whose length is not 4KB-aligned
   leaves its final partial page unmapped.
9. **OpenCnt wrap path.** ++OpenCnt == 0 lands on the `_start`
   `moveq #-1` stub and returns -1 as the library pointer.
10. **readregs block overrun.** sv_readregs stores MMUSR as a LONG at
    +26, writing 30 bytes into the nominally-28-byte block (bytes
    +78/79 of the base are clobbered — a pad field, no live data).
11. **Adopted-SRP root re-derivation is inconsistent.** When active,
    +38 holds the raw SRP and is indexed directly; when !active, +38
    holds the trailer node and the table is re-derived via
    `(node[1]+0x1ff)&~0x1ff`.  Works, but the dual meaning of +38 is
    fragile.
12. **Detach on an adopted (active) config** skips the WriteRegs but
    still clears +38/+42 — the adopted table is never freed (correct)
    but a re-attach after detach-of-adopted must rebuild from scratch.
