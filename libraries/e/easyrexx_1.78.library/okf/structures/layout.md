# easyrexx.library 1.78 — structures & data layout

## Hunk map

| hunk | type | size | notes |
|------|------|------|-------|
| 0 | CODE | 2772 B (0x2b5 LW) | all code + embedded strings + functab |
| 1 | DATA | 24 B (6 LW) | InitTable + near-data pad |

RELOC32 (0x3ec) groups: h0->h0 23 offsets, h0->h1 7 offsets
(0xa9c,0xa80,0xa68,0xa50 tail thunks + 0x86,0x74 initfn `lea _gd`
+ 0x1a romtag rt_Init); h1->h0 2 offsets (+8 functab, +0x10 initfn).
Producer order is nonstandard (descending then ascending); fixup.py
reproduces it verbatim.

## hunk1 (_gd, 24 B)

| off | content |
|-----|---------|
| +0  | 0 — dead rebase-entry count (initfn loop never runs) |
| +4  | InitTable: dsize=0x54, ftab->h0+0x9d4, dtab=0, initfn->h0+0x20 |
| +0x14 | 0 — spare |
| +0x18 | **OUT OF BOUNDS** — read by the four rexxsyslib thunks as
        `movea.l (gd+0x18).l, a6`; beyond the 24 B allocation, never
        written anywhere (latent defect) |

## library private data (lib+0x30 .., dsize 0x54)

The initfn copies h1's 24 bytes into lib+0x30..0x47, so
lib+0x38 = absolute functab ptr, lib+0x40 = initfn ptr (unused).
Dependency bases:

| lib+ | content |
|------|---------|
| +0x48 | rexxsyslib base (opened v0 — any version) |
| +0x4c | utility base (v37) |
| +0x50 | dos base (v37) |

## host object (created by -84, size 0x22+4*maxargs)

| off | content |
|-----|---------|
| +0    | MsgPort ptr (ln_Pri=1, ln_Name->dup'd unique name) |
| +4    | argstruct ptr (tag 0x80000002); +8 in it -> arglist str |
| +8    | command buffer (sprintf target) |
| +0xc  | dup'd port name ('EASYREXX'/name or name.N) |
| +0x10 | max arg count (commas+1 rounded) |
| +0x12 | dos object handle (dos -0xe4, type 5) |
| +0x16 | current inbound msg ptr (-90 writes) |
| +0x1a | flag long (bit0 cleared by -102) |
| +0x1d | flag byte: bit0 = args inited (-66), bit1 = port added (-84) |
| +0x1e | selected cmd key |
| +0x22 | arg slots[] |

## embedded h0 data islands

`EASYREXX\0`@0x17a, `AREXX\0`@0x183, tag template
`{0x80000003,0,0,0}`@0x18a, `rexxsyslib.library`@0x19a,
`utility.library`@0x1ae, `dos.library`@0x1be, `%s.%ld`@0x1ca,
`%s%s`@0x1d2, word `0x0a00` (a "\n" string!)@0x1d8, functab@0x9d4,
name@0xa1c, idstr@0xa30, `lib`@0xa4a, thunk code @0xa4c..0xad4.
