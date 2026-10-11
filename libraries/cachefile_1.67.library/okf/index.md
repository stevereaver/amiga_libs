# cachefile.library 1.67 (25.8.94) — OKF index

Binary: `binary/cachefile_1.67.library` (1580 bytes, single CODE hunk)
ID string: `assembler/library/cachefile 1.67 (25.8.94)`
Copyright: `© Ralph Schmidt 1993` (embedded, kept verbatim — required for
byte-faithful header reconstruction of this specific artifact)

## What it is

A disk-file cache. `CacheFile_Load` reads an entire file into a named,
semaphore-protected node list and arms a dos `StartNotify` on it. At
init the library spawns an embedded process, **CacheFile_Notify**,
which executes code inside the library's own hunk (CreateNewProc
NP_Seglist = BPTR into the code hunk) and transparently re-caches any
watched file when dos posts a change notification.

## Vectors (11 + -1L terminator, LONG absolute functab @ hunk+0xa0)

| LVO | Target | Function |
|----:|--------|----------|
| -6  | 0x19a | LibOpen — opencnt++, clear flag3, ret base |
| -12 | 0x1a8 | LibClose — opencnt--, flag3 path branches to stub |
| -18 | 0x1be | **stub: return 0** (expunge unreachable — defect) |
| -24 | 0x22e | reserved: return 0 |
| -30 | 0x38a | `CacheFile_Find(a1=name)` — case-fold list walk |
| -36 | 0x3f4 | `CacheFile_Load(d0=fh, a1=name)` — read file into node |
| -42 | 0x534 | `CacheFile_Free(a1=node)` |
| -48 | 0x50c | `CacheFile_FreeAll()` — **deadlocks** (defect) |
| -54 | 0x504 | `CacheFile_GetList()` — returns `&base->list` |
| -60 | 0x5b8 | `CacheFile_Data(a1=node)` — returns data ptr |
| -66 | 0x5c0 | `CacheFile_Size(a1=node)` — returns filesize |

## Files

- `source/cachefile_lib.s` — RomTag, strings, InitTable, functab,
  datatab, initfunc (process spawn), open/close/stub/dead-expunge,
  embedded daemon @ hunk+0x23c, semaphore helpers, statics
- `source/cachefile.c` — all seven API functions + `cf_freenodes`
- `okf/log.md` — session log
- `okf/functions/vectors.md` — per-vector detail
- `okf/structures/layout.md` — base + node layouts
- `okf/findings/defects.md` — shipped defects
