---
type: Finding
title: Inconsistencies found
description: Header bugs, API quirks and source-level nits discovered while reverse engineering.
timestamp: 2026-10-10T00:00:00Z
---

# Inconsistencies

1. **`GZ_FGetC` / `PPCGZ_FGetC` return type wrong in public header.**
   `include/clib/zlib_protos.h` declares `long *GZ_FGetC(APTR)` and
   `long *PPCGZ_FGetC(struct Library *,APTR)` — both should be `long`
   (gzgetc returns an int char code / -1). Pointer return type is a bug in
   the shipped developer header.

2. **`PPCGZ_FileLength` macro broken in `zlib_protos.h` (__STORMGCC__ branch).**
   The `#define PPCGZ_FileLength(gzhandle)` line lacks the trailing `\`, so
   the expansion body becomes a stray statement — file won't compile for
   StormGCC users as shipped.

3. **68k vs PPC clamp logic diverges in `GZ_CompressMem`.**
   `func.c`: `if(level>9) level=9;` only. `func_ppc.c`: also
   `if(level<0) level=0;` — dead code anyway (`level` is ULONG) but an
   inconsistency between the twin implementations.

4. **`GZ_DecompressMem` reports no output length.**
   Unlike `GZ_CompressMem` (which has `poutlen`), the decompress call gives
   the caller no way to learn how many bytes were produced — mirrored in the
   PPC twin.

5. **`GZ_FileLength` reads gzip ISIZE naively.**
   Seeks to -4 and reads the last 4 bytes little-endian — returns garbage for
   transparent (non-gzip) streams, multi-member files, or files <4 bytes;
   no handle validation.

6. **`gzio.c`: `s->file = NULL` assigns pointer-null to `BPTR` (long).**
   Fine under StormC (NULL=0); modern GCC flags int-conversion —
   `-Wno-int-conversion` needed to build.

7. **FD files disagree on PPCGZ_* visibility.**
   `include/zlib_lib.fd` (Developer/FD) marks `PPCGZ_*` `##public`;
   `source/zlib_lib.fd` (Developer/SRC) marks them `##private`. Both produce
   the same 24-entry vector table — purely cosmetic, but the published FD
   contradicts the author's own intent to keep PPC entries private.

8. **`getmode()` silently rejects `MODE_READWRITE` (1004).**
   Only MODE_OLDFILE/MODE_NEWFILE accepted — an unusual-but-documented
   restriction; MODE_READWRITE gz-open attempts return NULL with no error.

9. **InitTable opcode words differ from NDK macros.**
   StormC emits `0x8000/0x9000/0xa000` for INITLONG/WORD/BYTE vs the
   documented `0xc000/0xd000/0xe000` — both accepted by exec InitStruct;
   fields decode correctly either way.

10. **`compress.c` / `uncompr.c` ship in the archive but are unreachable.**
    No LVO exposes `compress*`/`uncompress*` — GZ_*Mem functions re-implement
    the same one-shot pattern inline.

11. **README history:** v3.1 "didn't work on plain 68k" — v3.2 fix suggests
    `powerpc.library` dependency (`sLibBaseC ... ,FALSE`) was made non-fatal;
    on 68k-only systems the PPC LVOs exist but are uncallable.
