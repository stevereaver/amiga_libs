# mhimpegit.library 4.0

- **Binary**: `binary/mhimpegit_4.0.library` (2132 bytes)
- **Version string**: `$VER: mhimpegit.library 4.0 (22.05.2022)`
- **Author**: Thomas Wenzel (embedded string, returned by -78 for code 1002)
- **Product name**: "MPEGit" (embedded string, -78 code 1000)
- **CPU**: requires 68020+ (BSR.L, `aN@(bd)@(od)` memory-indirect
  addressing, `divu.l`)
- **Structure**: 3 hunks — CODE 1692B, DATA 84B, BSS 16B. AUTOINIT via
  RomTag at code+0x140 whose `rt_Init` is a **data-hunk** relocation to
  the InitTable at data+4.
- **Role**: thin wrapper over `prelude.library` v4. Maintains per-object
  MinLists of 24-byte records and forwards tagged calls to prelude
  vectors -90/-60/-84/-36.

## Vectors

| LVO | Name | Args | Result |
|---:|---|---|---|
| -6 | Open | a6=lib | lib; OpenCnt(+32).w++, clears flag3 @+14 |
| -12 | Close | a6=lib | OpenCnt--; at 0 + flag3 -> expunge |
| -18 | Expunge | a6=lib | deferred flag3 if open, else expunge |
| -24 | stub | — | 0 |
| -30 | Create | a0=tag0, d0=tag1 | obj* or 0 |
| -36 | Destroy | a3=obj | frees obj + closes prelude |
| -42 | Append | a0=v0, d0=v1, a3=obj | 1 (or arg1&~0xffff on NULL obj) |
| -48 | Pop | a3=obj | node data0, gated on prelude flag >= count |
| -54 | Query | a3=obj | `(obj & ~0xff) \| !flag` — sloppy |
| -60 | Iterate | a3=obj | prelude@-60 per unflagged node |
| -66 | Drain | a3=obj | prelude@-84/-36, Delay(35), frees all |
| -72 | stub | — | bare rts (stale d0) |
| -78 | Classify | d1=code | 1 for success codes / string ptrs 1000-1002 |
| -84 | Dispatch | d0=op, d1=val, a3=obj | prelude@-90 single tag |

See `functions/vectors.md`, `structures/layout.md`,
`algorithms/behavior.md`, `findings/defects.md`.

## Rebuild

`source/` contains `mhimpegit.c` + `mhimpegit_lib.s` + `Makefile`
(`m68k-amigaos-gcc -m68020`, HUNK output). Verified against the original
under a Musashi 68020 oracle: init fields, create/append/pop/drain/
destroy sequences, all 7 dispatch tags, classify map, expunge paths —
identical modulo heap-luck OOB reads documented as defects.
