# reqattack.library 0.03 -- OKF Index

- **Binary:** `binary/reqattack_0.03.library` (1372 bytes,
  5 hunks: 0x3e0 code + four tiny data hunks,
  SAS/C-style manual-init layout)
- **ID string:** `reqattack.library 0.03 (22.10.01)`
- **RomTag:** RTF_AUTOINIT set but **RT_INIT = 0** --
  decorative; the library is NOT built by InitResident
- **Loader contract:** a private loader reads the manual
  InitTable (hunk2 = {libSize 0x38, funcTable, 0, initFn})
  and calls MakeLibrary itself
- **lib_Version/Revision:** 0/3
- **Reconstruction:** `source/` builds with
  `m68k-amigaos-gcc -m68000` (absolute-longword functab)

## Purpose

"ReqAttack SubLibrary" -- a proxy library for the
ReqAttack requester auto-answering tool.  Its two public
vectors wrap intuition's `EasyRequestArgs` (-588) and
`BuildEasyRequestArgs` (-594).  Each call is forwarded to
the "ReqAttack Warp Core" service first: a
`FindPort("ReqAttack Warp Core")` lookup yields a port
whose **+46 field holds a mini jump-table base**; the
proxy calls slot -30 (RARequest) or -36 (RABuildRequest)
on that base.  A return of -3 means "not handled" and the
real intuition function runs as fallback.

Hand-off is serialised by a shared
`FindSemaphore("ReqAttack SubLibrary")` +
`AttemptSemaphoreShared` + `ReleaseSemaphore` bracket.

## Public vectors

| LVO | Name | Notes |
|-----|------|-------|
| -6 | LibOpen | OpenCnt++, clears DELEXP |
| -12 | LibClose | OpenCnt--, delayed expunge |
| -18 | LibExpunge | CloseLibraries + Remove + FreeMem |
| -24 | 0 | reserved |
| -30 | RARequest | proxy for intuition EasyRequestArgs |
| -36 | RABuildRequest | proxy for BuildEasyRequestArgs |

## Exec LVO inventory

-132 Forbid, -138 Permit (x2 per call -- see findings),
-252 Remove, -210 FreeMem, -390 FindPort, -414
CloseLibrary, -552 OpenLibrary, -570 ReleaseSemaphore,
-594 FindSemaphore, -720 AttemptSemaphoreShared.

## intuition LVO inventory

-588 EasyRequestArgs, -594 BuildEasyRequestArgs
(fallback paths only).

## Layout

- hunk0 code 0x3e0: entry stub, RomTag (init=0),
  LibInit@0x20, LibOpen@0xc4, LibClose@0xd6,
  LibExpunge@0x100, OpenLibraries@0x158,
  CloseLibraries@0x190, Fn1@0x1c8, Fn2@0x290,
  strings, 6-long vector table @0x38c.
- hunk1 (8B): SAS/C far-data fixup table {0,0} --
  an empty template, the fixup loop never fires.
- hunk2 (16B): the manual InitTable
  {0x38, ->functab, 0, ->LibInit}.
- hunk3 (8B): {SysBase stash, intuition.library base}.
- hunk4 (4B): {WarpCore base} -- written from port+46
  on every proxied call.
