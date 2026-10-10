# Framework

## LibInit (@0x74)

a5 = base; SysBase -> +0x2a, seglist -> +0x2e; d7 = 0x800c.
Shared open-helper @0xbc: `OpenLibrary(name, 37)` for
"utility.library" -> +0x26; on NULL: close both bases,
`orl #0x30000,d7` -> Alert(0x3800c), init returns 0.
Then InitSemaphore(+0x32), inlined NewList(+0x60),
InitSemaphore(+0x6c), nipc@+0x22 = 0, return base.

## LibOpen (@0x100)

If nipc@+0x22 is NULL: ObtainSemaphore(+0x6c);
OpenLibrary("nipc.library", 0) -> +0x22; if opened,
nipc -66(a0 = services libbase) to register the client;
ReleaseSemaphore(+0x6c).  OpenCnt++, clear DELEXP;
return base iff nipc opened, else 0.

## LibClose (@0x152) / LibExpunge (@0x172)

Standard deferred-expunge pair.  The expunge path
nipc -66(a0 = 0) to unregister, then removes the node,
CloseLibrary(nipc), CloseLibrary(utility) via the shared
helper @0x1d6, frees the 342-byte node list at +0x60
(@0x1e8 loop: RemHead -> FreeMem(342)), FreeMem(base).

## Notes

- datatab only initialises lib_Revision = 10; the version
  field comes from the RomTag (37).
- The fail path inside LibInit calls CloseLibrary on the
  nipc slot before it is ever written -- benign because
  AUTOINIT bases are clear-allocated, but sloppy.
- LibOpen returns NULL (not the base) if nipc failed to
  open -- callers can detect the missing dependency.
