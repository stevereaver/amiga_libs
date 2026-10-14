# accounts.library 37.5 — quirks & defects

1. **RELOC32 order**: offsets stored `0xa` before `0x6` — the RomTag
   EndSkip relocation precedes MatchTag, the reverse of source order
   (likely an artifact of the original Amiga assembler/linker's
   reloc flush order). fixup.py restores the exact sequence.

2. **Word-offset functab**: the functab starts with `0xffff`, selecting
   MakeLibrary's word-offset form (offsets relative to the functab base)
   rather than the absolute-long-pointer form used by sibling
   reconstructions (asyncio, dospath). 19 vectors, `0xffff` terminated.

3. **functab order ≠ code order**: entries 8/9 point at 0x876/0x7de,
   then entry 10 jumps back to 0x308 — the compiler emitted functions in
   a different order than the API vector list (entries 8,9,17,18 are the
   'q','t',hash,'u' routines which sit at the end of the hunk).

4. **Dead code**: `_sprintf` (RawDoFmt wrapper, 0xa3c) and its `_putch`
   sink are never referenced. The `moveq #-1,d0;rts` at hunk+0 is
   unreferenced (not in the functab; probably a vestigial module-init
   stub from the runtime the image was linked with).

5. **`2f0e 2f0e` double-push**: vectors -30/-36 push a6 twice before the
   AllocMem call and pop it twice after — a compiler prologue artifact
   (dead extra stack slot), transcribed verbatim.

6. **Stale pointers after failed Open**: on ctx-create or find-service
   failure, lib+34 (NIPCBase) and lib+54 (ctx) are left non-NULL but
   dangling (the objects are freed/closed). Harmless: the retry gate is
   `lib+58==0`, and both fields are unconditionally overwritten on the
   next attempt. Not a refcount leak either — the nipc.library close
   still runs.

7. **`_sendreq` drops GetMsg result**: after WaitPort it calls GetMsg
   and discards the return value; success is signalled purely by the
   object fields the server side wrote (obj+30). A reply-less port would
   still count as "sent".

8. **Nonstandard arg registers**: public vectors take args in a0, a1
   *and a2* (-54/-114 push the caller's a2 as a stack arg for the shared
   worker; -108 reads a2 directly). d0 also carries a word arg for
   'm'/'o' and the command selector inside the 'q'/'u' wrappers.

9. **Password-hash specifics** (-108): the input name buffer (a2) is
   lowercased into all 32 local slots but only the first 12 feed the
   mix; the source strings walk with a sticky-NUL (once exhausted, the
   loop index is substituted); the rolling `%53` loop mutates mix[k]
   in place while summing, so terms already reduced for earlier output
   positions feed later ones, and mix[k] itself is among the addends
   (when 11−i == k it doubles before the mod). Output is 11 printable
   bytes (sum%53 + 'A') + NUL; out[11] is computed then clobbered by
   `clrb a2@(11)`.

10. **No header init in initfn**: ln_Type/ln_Name/lib_Flags/
    lib_Version/lib_IdString are never stored — this AUTOINIT library
    relies on exec's InitResident to copy them from the RomTag. The
    datatab contributes only `lib_Revision=5`.

11. **Semaphore guarding**: Open's lazy service bind and Close's
    teardown run under ObtainSemaphore on a SignalSemaphore embedded in
    the library data (lib+62), with a `0xc0edbabe` canary at lib+108
    immediately after it — the canary is write-only (never checked).

12. **'t' vector asymmetry** (-60): unlike the other request vectors it
    does no reply copy-out and doesn't gate on obj+30==0 — it just
    returns the server status.
