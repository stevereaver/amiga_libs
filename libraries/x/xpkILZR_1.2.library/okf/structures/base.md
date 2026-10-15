---
type: Structure
title: xpkILZR 1.2 library base
---

# IlzrBase — dataSize 0x114

```
+0x00  struct Library (0x22 bytes, standard node)
+0x22  seglist (LibInit)
+0x26  [8 pad]
+0x2e  fixup-offsets list ptr — ALWAYS 0 (dead Open path)
+0x32  master back-pointer (self on master, master on copies)
+0x36  copy bias = 0x3c
+0x3c  descblock[192] — hunk copy: $VER string, mode record,
       XpkInfo at +0x62 (→ base+0x9e), minsize long at +0xbc
+0xfc  [12 pad]
+0x108 ioerr — suballoc error code (12 alloc-fail, 22 req==0)
+0x10c memflags — suballoc MemFlags (0 on this build)
+0x110 freelist — suballoc block chain (append-only, leaks)
```

The descblock copy means +0xf8 (minsize) carries 0x1000 —
the last long of the copied block (`00 00 10 00`).

Per-open copies allocate `0x114+0x3c` = 0x150 bytes and keep
the copy bias; the copy's vectors point into the MASTER hunk
(the copied vectors' jump entries were generated code — hence
CacheClearU after the memcpy).

Wait — actually no: the vectors are copied BY VALUE
([base-0x3c, base+0xfc) includes the negative-size region:
the real jump-table slots).  Calls into a copy land on the
copy's own jump stubs which JSR the same code addresses.
