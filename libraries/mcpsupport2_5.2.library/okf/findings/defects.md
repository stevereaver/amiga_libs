# mcpsupport2.library — shipped defects & inconsistencies

## 1. Version mismatch

The file is named `mcpsupport2_5.2.library` but the library
reports **5.0**: RomTag rt_Version=5, InitStruct
lib_Revision=0, and the idstring is
"$VER: MCPSupport2.library 5.0 (14.10.98)".  The 5.2 is only
in the filename.

## 2. Leaked library bases on Expunge

`Expunge` frees the 12-byte aux block and the library base,
but never calls `CloseLibrary` on the dos.library and
utility.library bases it opened in `InitFunction`.  Every
expunge therefore leaks two open-count increments — the two
system libraries can never be fully closed/flushed while
this library was resident.

## 3. Reserved vector points at the entry stub

Vector -24 (reserved/ExtFunc) points at the `_start`
routine (`moveq #-1,d0; rts`) — calling it returns -1
rather than the more conventional 0.

## 4. mcpLoadFile returns two registers

`-30` returns the buffer in d0 AND the size in d1 — a
non-standard dual-register ABI; C prototypes exposing only
the pointer lose the size.
