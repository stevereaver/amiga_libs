# Findings / defects / quirks — explode 7.0

1. **Version inconsistency.** `rt_Version`=7 and the idstring says
   "7.0", but the datatab initialises `lib_Version`=6, `lib_Revision`=0.
   Anything keying on `lib->lib_Version` sees 6.0.

2. **Init fails open.** `OldOpenLibrary("dos.library",37)` failure
   skips the whole wedge install but still returns the library base —
   MakeLibrary/AUTOINIT reports success and the library registers with
   `eb_DosBase`=0.  A subsequent last-close expunge would then call
   `SetFunction`/`CloseLibrary` on a NULL dos base.

3. **No wedge-identity checks anywhere.**  Install stores whatever
   SetFunction returns into the stub's `jsr` operand without verifying
   the slot was a plain `jmp` vector; expunge blindly SetFunctions both
   slots back, stomping any newer hook installed after us.  (5.6.29
   did both checks.)

4. **-18/-24 expunge vectors are dead** (`moveq #0;d0;rts`).  The real
   expunge only runs from Close with +34-bit3 armed by -36 — an
   OS-level RemLibrary expunge silently no-ops and leaves both dos
   vectors pointing at freed memory.

5. **-30 Explode decrements `lib_OpenCnt` unconditionally** — every
   call consumes an open; unpaired calls drive the count negative.

6. **-30 never returns to its caller**: it writes `hunk0+4` into the
   stack slot the final `rts` pops — it *enters* the inflated segment.
   Callers must treat it as load-and-jump, not call.

7. **Unconditional `CacheClearU`.**  Called at init, after each wedge
   inflate, and by -30 — correct on V37+ (which the dos open gate
   implies) but undocumented anywhere; on hypothetical sub-37 exec the
   call would jump into unused vector space.  The gate is the only
   thing making this safe.

8. **Second signature variant is incompletely checked**: the
   "ed explode.libra" path never verifies the trailing "ry\0" —
   16 bytes at hunk+40 suffice to trigger inflate.

9. **Frame is stack-allocated across a coroutine** — the 54-byte a4
   frame is created below the caller's regs and the decoder parks
   state in it across bsr/rts boundaries; an interrupt can't hurt it
   but the scheme depends on nobody else touching that stack area.
