# log

- **RE session**: decoded the 3-hunk SAS/C manual-init binary. INIT at the data section: dataSize 0xe0, FUNCTABLE, InitFunction. The InitFunction manually fills Library fields and copies a context template; LAB_0013 (per-open ctx init) opens `dos.library`@ctx+68 and `utility.library`@ctx+72 (both v33) via `OpenLibrary(-552)`. Strings: `dos.library`@0x4de, `utility.library`@0x4ea, name@0x550, idstr@0x564.

- Resolved LVOs: -246 AddTail, -252 Remove, -210 FreeMem, -414 CloseLibrary, -552 OpenLibrary, -558 InitSemaphore, -564 ObtainSemaphore, -570 ReleaseSemaphore, -576 AttemptSemaphore, -684 AllocVec, -690 FreeVec.

- Node layout (RegisterShutdown): `{MinNode@0, name@8, callback@12, namebuf@16}` — AllocVec(16+len+1, PUBLIC|CLEAR), name copied inline, AddTail under sem1.
- LIBFUNC_3 = FireShutdown: `AttemptSemaphore(sem2)`; on success iterate the list calling each node callback via a thunk, then `ReleaseSemaphore`.
- Reconstructed as AUTOINIT + inline Ctx struct; built clean with m68k-amigaos-gcc -O2 -m68000.
