# xpkDMCU 41.0 — layout

## Hunks

| hunk | type | size field | body | contents |
|------|------|-----------|------|----------|
| 0 | CODE (0x3e9) | 0x1f6 longs | 2008 B | init/lib skeleton, 6 API vectors, string islands, native coder |
| 1 | DATA (0x3ea) | 0xd4 longs | 848 B | InitTable, functab, datatab, packed RomTag, strings, info tables |

RELOC32 groups in the original use a non-monotonic (unsorted) offset
order per hunk; `source/fixup.py` rewrites the GNU-emitted groups into
the original order.

## h1 DATA map (also `_gd` near-data base)

| off | contents |
|-----|----------|
| 0x00 | InitTable: `dsize=0x36, ftab->h1+0x10, dtab->h1+0x100, initfn->h0+0x0e` |
| 0x10 | functab: 10 longs + `0xffffffff` (offsets into h0) |
| 0x3c | `_gd+0x3c`: lib base (stored by initfn) |
| 0x78 | `_gd+0x78`: exec base |
| 0x7c | `_gd+0x7c`: ppc.library base (or 0) |
| 0x80..0x94 | ppc objects: ELF handle, ports, job objects |
| 0x98 | `"xpkDMCU.library"` name |
| 0xa8 | `$VER` idstr |
| 0xe4 | packed RomTag (name->0x98, idstr->0xa8, init->h1+0) |
| 0x100 | datatab (InitStruct command stream) |
| 0x128+ | object-name/tag strings used by init (`'PORT'`, 0x8002xxxx tags) |
| 0x2f4 | xpk info table returned by vector -30 (`+0 = 0x00010001`) |
| tail | `"DMCU"`, `"Dynamic Markov Coding Ultra"`, `"Arithmetic coding using Markov modelling"`, `"Compressing  "/"Decompressing"`, `"Compressed   "/"Decompressed "`, size-label table `8192 K`..`64 K` with pointer table |

## Library header (built by datatab + initfn)

`ln_Type=9, ln_Flags=0x06(+DELEXP), lib_Version=41, lib_Revision=0,
lib_NegSize=60, lib_PosSize=88, lib_IdString->$VER, seglist@+0x22,
exec@+0x26, ppc triple @+0x2a/+0x2e/+0x32`.
