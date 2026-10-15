# Vectors / library interface

Ten-vector **longword-pointer** functab (code+0x2e, terminated by
`0xffffffff`) — not the word-offset form used by the 1.8
generation. Two null vectors exist, and unlike 1.8 they do *not*
share the entry stub: -24 has its own stub at code+0x104, -48
another at code+0x134 (which is also bsr-called from LibInit and
Expunge as a do-nothing routine). The entry stub at code+0 returns
**-1** (`70ff 4e75`) and is not referenced by the functab.

| off  | name            | code+ | behavior |
|------|-----------------|-------|----------|
| -6   | Open            | 0x09e | `lib_OpenCnt++`, clears LIBF_DELEXP, returns libbase |
| -12  | Close           | 0x0ac | `d0=0; --lib_OpenCnt`; if 0 && LIBF_DELEXP → bsr Expunge; rts |
| -18  | Expunge         | 0x0c0 | if opencnt≠0 → set LIBF_DELEXP, ret 0; else `Remove` (LVO -252), **dead bsr to the 0x134 stub**, `FreeMem(lib-negsize, negsize+possize)` (LVO -210), returns seglist read from **code+0x7a** |
| -24  | null            | 0x104 | `moveq #0,d0; rts` |
| -30  | XpksPackerInfo  | 0x986 | `lea DATA+0x2a,a0; move.l a0,d0; rts` |
| -36  | XpksPackChunk   | 0xa58 | see algorithms/codec.md |
| -42  | XpksPackFree    | 0x990 | frees Sub[1] (0x8000), tab1 (0x20000), tab2 (0x10000), header (92); **clears both Sub pointers**; returns FreeMem's leftover d0 = 0x5c |
| -48  | null            | 0x134 | `moveq #0,d0; rts` (also the dead bsr target) |
| -54  | XpksUnpackChunk | 0xae2 | lazy-allocs Sub[1] (0x8000, MEMF_ANY) if absent → -7 on failure; decodes into scratch, integrates into OutBuf; always returns 0 |
| -60  | XpksUnpackFree  | 0xb3c | frees Sub[1] (0x8000) if set and clears it; returns leftover d0 = 0x8000, else 0 |

## Init

- RomTag at code+4: RTF_AUTOINIT(0x80), ver 1, NT_LIBRARY(9), pri 0.
- `rt_EndSkip = code+0x106` — just past the -24 stub (the rts).
- InitTable at code+0x1e: dataSize **0x22** = bare `struct Library`
  (no private data!), functab@0x2e, datatab@0x5a, LibInit@0x7e.
- LibInit (code+0x7e): pushes a5, a5=libbase, stores a0 (seglist)
  at **code+0x7a** via a relocated absolute store — a
  self-modifying in-code variable sitting in the pad gap between
  datatab and LibInit. Then `bsr 0x134; tst.l d0; bne fail` —
  dead check (the stub always returns 0); returns libbase.
- datatab: ln_Type=9, ln_Name→"xpkDUKE.library", lib_Flags=6
  (LIBF_CHANGED|LIBF_SUMUSED), version=1 revision=6,
  idstring→"xpkDUKE 1.6 (08.06.1997)\r\n" (**no `$VER:` prefix**).
- neg size = 60 (10 vectors), pos size = 34 + 34 = 68;
  Expunge frees 60+68 = 128 bytes.

## Lifecycle trace (oracle, original == rebuild)

```
open -> libbase, opencnt 1 → 2
expunge(open) -> 0, flags 0e (LIBF_DELEXP set)
close -> 0, opencnt 1
close -> 5a0000 (saved seglist), opencnt 0 → deferred expunge fires:
  Remove(lib); dead bsr stub; FreeMem(libbase-neg, 128)
```

## Pack/unpack call convention

a0 = `struct XpkSubParams *`, a6 = libbase, return in d0:

- `XpksPackChunk`: 0 on success, -7 alloc failure, -17 expansion
  (outlen > inlen or writeback overflow). xsp_OutLen is written
  before the success gate, so -17 paths leave 0xffffffff or a
  too-large count there.
- `XpksUnpackChunk`: always 0 (or -7 on lazy-alloc failure).
- `XpksPackFree` / `XpksUnpackFree`: FreeMem leftover d0 or 0.
