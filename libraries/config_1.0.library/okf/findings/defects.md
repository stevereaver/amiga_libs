# config.library — quirks and defects

1. **Version field disagreement**: RomTag `rt_Version` and the
   InitStruct datatab both say **3.0** while the idstring reads
   `config 1.0 (12.10.96)` — a real versioning inconsistency in the
   shipped binary.

2. **Hunk-table size quirk**: the HUNK_HEADER allocates hunk1 at
   0x56 longs while the DATA hunk's own size field says 0x55 — the
   loader reserves one longword more than the body contains.
   Reproduced verbatim by fixup.py.

3. **`_setnum`/`_getnum` FreeVec a stack address**: both wrappers
   sprintf into a stack buffer then pass that stack pointer to
   exec FreeVec — on a real system this corrupts the memory lists
   (observed identically in original and rebuild: freevec of an
   address inside the caller's stack frame).

4. **Return values are sloppy**: `_setnum`/`_getnum` return the
   low-word of a stack pointer region rather than a clean status —
   callers should ignore the result (getnum returns the parsed long,
   setnum's return is garbage).

5. **Dead helpers**: `_r0a`,`_r1a`,`_r0b`,`_r1b` (constant 0/1 stubs)
   and `_null0` are emitted but unreferenced.

6. **Scrambled RELOC32 groups**: the original linker wrote reloc
   offsets in non-ascending order within each group — preserved by
   fixup.py ordering tables.

7. **`pea 0x25.w` / `pea 0x3ed.w`** (`.short 0x4878,imm`): SAS/C
   pushes small constants via absolute-short pea — gas won't emit the
   form; raw-emitted.
