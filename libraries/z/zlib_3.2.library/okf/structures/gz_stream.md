---
type: Structure
title: gz_stream
description: Per-handle state returned by GZ_Open / gzdopen (98 bytes, AllocVec).
---

# gz_stream

Amiga-adapted version of zlib 1.1.4's `gz_stream` (`source/gzio.c`); allocated
98 bytes via `AllocVec(..., MEMF_PUBLIC|MEMF_CLEAR)`:

```c
typedef struct gz_stream {
    z_stream stream;      /* 56 bytes */
    int      z_err;       /* 56 */
    int      z_eof;       /* 60 */
    BPTR     file;        /* 64 — dos.library file handle (not fd!) */
    Byte    *inbuf;       /* 68 */
    Byte    *outbuf;      /* 72 */
    uLong    crc;         /* 76 */
    char    *msg;         /* 80 */
    char    *path;        /* 84 — strdup'd open path */
    int      transparent; /* 88 */
    char     mode;        /* 92 — 'r' or 'w' */
    long     startpos;    /* ... */
} gz_stream;
```

Differences from stock gzio: `file` is a `BPTR`; I/O goes through
`FRead/FWrite/Seek/Close/Open` (dos.library); buffers are
`Z_BUFSIZE`=16384 (0x4000 seen in disasm); `ALLOC`=`AllocVec`, PPC side uses
`AllocVecPPC(...,4)` (powerpc.library).
