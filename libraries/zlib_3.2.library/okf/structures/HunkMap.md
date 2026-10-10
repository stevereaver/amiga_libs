---
type: Structure
title: Hunk map
description: Binary layout — which hunk holds which ISA and code.
---

# Hunk map

| Hunk | Type | File off | Bytes | ISA | Contents |
|------|------|----------|-------|-----|----------|
| 0 | CODE | 0x34 | 44,392 | m68k | RomTag+AUTOINIT, StormC libinit, `GZ_*` API, complete m68k zlib (gzio/deflate/inflate/trees/inf*/crc32/adler32/zutil) |
| 1 | CODE | 0xb138 | 45,588 | PPC | `PPCGZ_*` entries + complete PPC zlib core |
| 2 | CODE | 0x1636c | 472 | PPC | small helper funcs (StormC mixed-binary glue) |
| 3 | DATA | 0x16550 | 14,260 | — | `_SysBase` marker, near-data reloc table, error strings, FUNCTABLE, name/id strings |
| 4 | DATA | 0x19e38 | 508 (+44 bss) | — | function-pointer tables (init/exit lists), misc |
| 5 | BSS | — | 644 | — | |

FUNCTABLE reloc split (entries = FUNC index): 0-10,18-19,22 → hunk0;
11-17,20-21,23 → hunk1. The PPC entries start with `mflr r0` — the vector
points directly at PPC code, valid only under a PPC-aware exec (WarpOS).
