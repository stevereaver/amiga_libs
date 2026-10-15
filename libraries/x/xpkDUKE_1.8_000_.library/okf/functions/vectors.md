# Vectors / library interface

Ten-vector word-offset functab (`0xffff` marker … `0xffff` terminator),
identical layout to xpkNUKE 1.8. Null vectors resolve to the entry
stub at code+0 (`moveq #0,d0; rts`), not a separate function — the
functab entries are `-functab` relative offsets.

| off  | name            | code+ | behavior |
|------|-----------------|-------|----------|
| -6   | Open            | 0xb8  | `lib_OpenCnt++`, clears LIBF_DELEXP, returns libbase |
| -12  | Close           | 0xc6  | `--lib_OpenCnt`; if 0 && LIBF_DELEXP → falls into Expunge; else returns 0 **by branching to the code+0 stub** (`6600 ff34` style long branch to offset 0) |
| -18  | Expunge         | 0xd8  | if opencnt≠0 → set LIBF_DELEXP, ret 0 via stub; else `Remove` (LVO -252), `FreeMem(negsize+possize)` (LVO -210), returns saved seglist |
| -24  | null            | 0x00  | entry stub |
| -30  | XpksPackerInfo  | 0x132 | `lea code+0x90c,a0; move.l a0,d0; rts` |
| -36  | XpksPackChunk   | 0x13a | see algorithms/codec.md |
| -42  | XpksPackFree    | 0x116 | FreeMem(xsp_Sub[0], **0x3005c**), **does not clear the pointer**; returns FreeMem's leftover d0 = 0x3005c |
| -48  | null            | 0x00  | entry stub |
| -54  | XpksUnpackChunk | 0x7ba | decode + delta post-pass; always returns 0 |
| -60  | null            | 0x00  | entry stub |

## Init

- RomTag at code+4: RTF_AUTOINIT(0x80), ver 1, NT_LIBRARY(9), pri 0.
- `rt_EndSkip = 0` (sic — the 1.8 generation quirk, shared with NUKE).
- InitTable at code+0x68: dataSize 0x26, functab, datatab, LibInit.
- LibInit (code+0xb0): `a1=d0` (libbase), stores seglist at
  `base+34`, returns libbase. No CPU/feature gate.
- datatab: ln_Type=9, ln_Name, lib_Flags=6 (LIBF_CHANGED|LIBF_SUMUSED),
  ver=1 rev=8, idstring.
- neg size = 60 (10 vectors), pos size = 34+38 = 72.

## Lifecycle trace (oracle, original == rebuild)

```
open -> libbase, opencnt 1 → 2
expunge(open) -> 0, flags 0e (LIBF_DELEXP set)
close -> 0, opencnt 1
close -> seglist, opencnt 0 → deferred expunge fires:
  Remove(lib); FreeMem(libbase-neg, 132)    [132 = 60+72]
```
