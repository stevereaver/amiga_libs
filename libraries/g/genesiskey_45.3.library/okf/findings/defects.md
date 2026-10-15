# Defects / quirks observed in the shipped binary

1. **`rt_Init` is not a pointer.** Value 16 = data-hunk offset of the
   InitTable.  `InitResident` on this RomTag would dereference address
   16 — the file only works with Genesis' custom loader.
2. **lib_Version is never set.** The InitTable has no data table, so
   MakeLibrary leaves Version=0; LibInit only writes Revision=3.  The
   installed library reports version 0.3 while the RomTag/IdString say
   45.3.
3. **68020+ hard requirement.** LibInit tests `AttnFlags & AFF_68020`
   (exec+297 bit1) and frees the entire library allocation returning
   NULL on 68000/010 — the library silently refuses to exist.
4. **Crossed tail stubs.** Functab entries -84 and -90 point at the
   last two identical empty stubs in swapped order — cosmetic
   generator artifact.
5. **Serial as data.** `"454545"` and `"AmigaOS 3.9"` live at fixed
   data-hunk offsets 0x20/0x120 returned by vectors -66/-78 — callers
   must add the loaded data-hunk base themselves; the vectors return
   raw offsets, not pointers.
6. **Dead dependency opens.** open_deps holds dos/intuition/utility
   bases for the library's lifetime but no function in the binary
   ever calls into any of the three — pure presence bookkeeping.
7. **`bsdsocket` handle leaked.** The -54 probe returns the
   OpenLibrary result directly — callers that don't CloseLibrary it
   leak a reference (or, viewed differently, the probe doubles as a
   "hold the stack open" helper).
8. **Run-as-program stub returns 30.** Executing the .library from
   the CLI hits the code+0 stub and exits RETURN_FAIL=30 — intended
   guard, but means the file is not a runnable program.
