# services.library 37.10 -- OKF Index

- **Binary:** `binary/services_37.10.library` (1292 bytes,
  sha256 336c2ba5, single code hunk, 1204-byte image)
- **ID string:** `services 37.10 (16.12.92)` (Commodore)
- **RomTag:** `RTF_AUTOINIT`, version 37, `NT_LIBRARY`, pri 0
- **lib_Revision:** 10 (datatab sets only the revision)
- **Library base (dataSize 0x9a):** nipc@+0x22, utility@+0x26,
  SysBase@+0x2a, seglist@+0x2e, SignalSemaphore@+0x32,
  List@+0x60 (342-byte nodes), SignalSemaphore@+0x6c
- **Deps:** utility.library v37 (init), nipc.library (lazy, open)
- **Reconstruction:** `source/` builds with
  `m68k-amigaos-gcc -m68000` (two-pass word-offset functab)

## Purpose

Commodore's nipc (Network IPC) service registrar -- the
OS-side client of nipc.library.  nipc's fd does not ship
with the NDK, so its LVOs are documented by offset.

## Public vectors

| LVO | Name | Notes |
|-----|------|-------|
| -6 | LibOpen | lazy nipc open behind sem2; ret 0 if nipc fails |
| -12 | LibClose | OpenCnt--, delayed expunge |
| -18 | LibExpunge | nipc unregister + close libs + free node list |
| -24 | LibNull | returns 0 |
| -30 | SvcControl | nipc entity registration/request (see fn doc) |
| -36 | SvcFormat | RawDoFmt into a caller buffer (stack args) |

## Exec calls used

OpenLibrary -552, CloseLibrary -414, Alert -108,
InitSemaphore -558, ObtainSemaphore -564,
ReleaseSemaphore -570, RemHead -258, Remove -252,
AllocMem -198, FreeMem -210, RawDoFmt -522.

## nipc calls used (offsets; fd unavailable)

-66 register/unregister client (a0 = libbase | NULL)
-126 entity create (a0 = taglist) -> anchor
-114 request-object alloc (a0 = taglist) -> 256B object
-138 entity find/bind (a0,a1,a2,a3 = &code) -> entity
-144 release entity ref (a0)
-150 transaction submit (a0 = obj, a1 = anchor)
-120 destroy entity (a1)
-132 tag-based cleanup (a0 = caller taglist)
