# mhimpegit.library 1.2

- **Binary**: `binary/mhimpegit_1.2.library` (2200 bytes)
- **Version string**: `$VER: mhimpegit.library 1.2 (20.01.2017)`
- **Author**: Thomas Wenzel (embedded string, -78 code 1002)
- **Product name**: "MPEGit" (embedded string, -78 code 1000)
- **CPU**: plain 68000 code (no 020+ instructions observed)
- **Structure**: 2 hunks — CODE 1696B, DATA 280B. **Not AUTOINIT**:
  a *packed* `struct Resident` sits at data+0x3c (flags 0, version 1,
  type NT_LIBRARY) with rt_Init → code+4, a stub that runs
  `OpenLibrary("dos.library",0)`, `MakeLibrary(functab,0,0,42,0)`,
  fills the lib header by hand, `AddLibrary`, and returns the base.
- **Role**: thin wrapper over `prelude.library` v5. Maintains per-object
  MinLists of 18-byte records and forwards tagged calls to prelude
  vectors -90/-60/-84/-36. Earlier sibling of mhimpegit 4.0
  (AMIGALIBS-102).

## Vectors

| LVO | Name | Args | Result |
|---:|---|---|---|
| -6 | Open | a6=lib | lib; OpenCnt(+32).w++, clears flag3 @+14 |
| -12 | Close | a6=lib | OpenCnt--; at 0 + flag3 -> expunge |
| -18 | Expunge | a6=lib | deferred flag3 if open, else expunge |
| -24 | stub | — | 0 |
| -30 | Create | a0=tag0, d0=tag1 | obj* or 0 |
| -36 | Destroy | a3=obj | frees obj + nodes, closes prelude |
| -42 | Append | a0=v0, d0=v1, a3=obj | 1 (or arg1&~0xffff on NULL obj) |
| -48 | Pop | a3=obj | node data0, gated on prelude flag >= count |
| -54 | Query | a3=obj | 1 if !obj or prelude flag clear, else 0 |
| -60 | Iterate | a3=obj | prelude@-60 per unflagged node |
| -66 | Drain | a3=obj | prelude@-84/-36, Delay(35), frees all |
| -72 | stub | — | stale d0 (push a4, lea, pop, rts) |
| -78 | Classify | d1=code | 1 for success codes / string ptrs 1000-1002 |
| -84 | Dispatch | d0=op, d1=val, a3=obj | prelude@-90 single tag |

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.

## Rebuild

`source/` contains `mhimpegit.c` + `mhimpegit_lib.s` + `Makefile`
(m68k-amigaos-gcc -m68020, nostdlib). Behaviour verified
instruction-for-instruction against the original under machine68k
(`work/oracle.py` + `work/exercise.py`, not committed).
