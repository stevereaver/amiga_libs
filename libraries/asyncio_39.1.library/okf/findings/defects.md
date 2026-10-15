# asyncio.library 39.1 — defects

1. **OpenAsyncFromFH never initialises a4** (h0+0x4a4).  Unlike every
   other entry point — and unlike asyncio 37.2 where vec36 loaded
   `lea _bss,a4` — the 39.1 stub pushes d5, marshals args and calls
   the shared open worker (h0+0x2b4), which dereferences `a4@(4)`,
   `a4@(8)`, `a4@(12)` for execbase/UtilityBase/DOSBase.  No hunk1
   reloc slot exists in 0x4a4..0x4b8 or inside the worker, so a4 keeps
   whatever value the *caller* had.  With a foreign a4 the first
   `jsr a6@(...)` goes wild (oracle: jsr to 0xfffffe8c region, sweep
   of INVALID reads, bogus return).  Works only if the caller's a4
   already holds the lib's globals block — e.g. a SAS/C small-data
   program whose a4==lib bss won't happen; in practice broken unless
   a4 happens to be preserved across a prior lib call.

   Verified: no `49f9` opcode / no hunk1 RELOC32 slot anywhere in
   0x2b4..0x4a2 (worker) or 0x4a4..0x4b8 (entry).

2. **Init failure calls CloseLibrary(UtilityBase) unguarded** —
   `_freelib` (h0+0xc2) checks only DOSBase; if dos.library opened but
   utility.library failed it calls CloseLibrary(0).  Same as 37.2.
   Oracle `utilfail` scenario: `closelib 131072, closelib 0`.

3. **Double dos Close on OpenAsync alloc failure** — the open worker
   closes the handle when AllocVec fails *and* ownsFH is set, then
   OpenAsync closes it again on the NULL return (oracle: two
   consecutive `dclose` calls on the same BPTR).

4. **mn_ReplyPort never initialised** — the embedded Message's
   mn_ReplyPort (file+46) keeps AllocVec garbage; only ln_Type, ln_Name
   and mn_Length are written.  Works because replies go through
   af_PacketPort, not the reply port.

5. **Unchecked mode index in OpenAsync** — `d2 = mode*2` indexes a
   3-word table with no range check; any mode ≥3 reads wild and the
   worker's `subql #2,d1` then falls through to ParentOfFH on whatever
   garbage handle Open() returned.

6. **Hidden mid-instruction branch targets** — `cmpiw` immediates that
   are real opcodes when entered at +2 (see quirks.md §4).  Not a
   runtime defect, but breaks naive disassemblers.

7. **rt_EndSkip points at Expunge** (h0+0x1a8) — resident modules scan
   only up to endskip, so the RomTag scan stops early; harmless.
