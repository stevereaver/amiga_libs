# dsp3210.library — defects & inconsistencies

1. **-36 exttab read reaches into caller's stack frame.**
   `dsp_loadimg` reads the external-symbol-table pointer at
   `entry_sp+12` (3rd stack slot past the return address) rather
   than through a register parameter. Public callers must push it
   as the third stack argument; the internal `dsp_loadfile →
   dsp_loadimg` call leaves garbage there (whatever `d4` the
   caller had saved) — benign only because UNDEF symbols are
   rare/absent in file-loaded images.

2. **-36 dead "reserved" argument.** The a2 input is stored to a
   local slot (`movel a2,sp@(48)`) that is never read; a2 is
   clobbered internally and restored normally. dsp_loadfile's
   a1 parameter exists only to feed this dead slot.

3. **-36 reloc write base is always desc[0].** All section
   relocations write relative to the *first* section's load
   address (plus 4 when F_EXEC). Correct only if section vaddrs
   in the linked image match the contiguous load order; a
   reordered or sparse image gets silently wrong fixups.

4. **-36 error path -2 is dead code.** `moveq #-2` at the end of
   the error block has no incoming branch — every bounds/magic
   failure returns -1 instead. (Contrast: -30 objsize does
   return -2 for bad section types.)

5. **-42 Examine result unchecked.** `dos_examine(lock,fib)`'s
   return value is ignored — a failed Examine leaves garbage in
   `fib_Size` (+124), feeding an arbitrary size to AllocMem/Read.
   Harmless in practice (Lock succeeded → Examine almost always
   works) but not robust.

6. **-36 UNDEF name path ignores big stroff.** The string-table
   offset is read as a 16-bit BE word (`rdword` at sym+6), so
   string-table offsets ≥ 64KB are truncated.

7. **-30/-36 symtab bound arithmetic can wrap.**
   `f_symptr + f_nsyms*18` is computed in 32 bits and compared
   unsigned; a hostile image with huge f_nsyms could wrap the
   bound below `len` and pass validation.

8. **-48 unload trusts caller layout.** Only checks 4-alignment
   + magic at desc-8; a wild aligned pointer whose -8 happens to
   read `0x32102011` frees arbitrary memory (inherent to the
   shipped tag scheme).
