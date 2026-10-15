# mhimpegit.library 1.2 — memory layout

## Hunks (file order)

| # | Type | Bytes | Notes |
|---|------|------:|---|
| 0 | CODE | 1696 | +0 `moveq #-1,d0;rts`; +4 LibInit; stubs+helpers |
| 1 | DATA | 280  | strings, packed RomTag, functab, globals, templates |

## DATA hunk (all offsets verified against relocs)

| off  | contents |
|-----:|---|
| +0x00 | "mhimpegit.library" (17+1) |
| +0x12 | pad byte 0 — **rt_IdString and lib+24 point HERE, not at "$VER"** |
| +0x13 | "$VER: mhimpegit.library 1.2 (20.01.2017)" (40+1) |
| +0x3c | packed RomTag (unaligned long fields) |
| +0x56 | functab: 14 code abs longs + -1 (rt_EndSkip also → here) |
| +0x92 | ExecBase slot (written by LibInit, re-read via `moveal 4` anyway) |
| +0x96 | DOSBase slot |
| +0x9a | libbase slot |
| +0x9e | "dos.library" + 2 pad bytes |
| +0xac | Create tag template, 32B: `{0x80000032,0, 0x80000033,0, 0x8000003f,0, 0,0}` |
| +0xcc | "prelude.library" |
| +0xdc | "MPEGit" + pad |
| +0xe4 | "1.2 (20.01.2017)" + pad |
| +0xf6 | "Thomas Wenzel" |
| +0x104 | Dispatch tag template, 16B: `{0x8000003f,0,0,0}` |
| +0x114 | PreludeBase slot |

## Library base (dataSize 42)

| off | field |
|----:|---|
| +8  | ln_Type = 9 (written by hand post-MakeLibrary) |
| +10 | ln_Name → data+0 |
| +14 | flags byte = 6 (bit3 = deferred-expunge) |
| +16/+18 | NegSize (84) / PosSize (42) — set by MakeLibrary |
| +20/+22 | version 1 / revision 2 |
| +24 | idString → data+0x12 (the pad byte — empty string) |
| +32 | OpenCnt |
| +34 | seglist |
| +38 | ExecBase |

## Create object (16 bytes, AllocVec flags 0x10000 CLEAR)

| off | field |
|----:|---|
| +0  | tag0 value (a0 arg) — echoed into prelude tag 0x80000032 |
| +4  | tag1 value (d0 arg) — echoed into prelude tag 0x80000033 |
| +8  | node count (Append++/Pop--) |
| +12 | → 12B MinList block (separate AllocVec 0x10001 PUBLIC|CLEAR) |

## Node (18 bytes, AllocVec 0x10001 PUBLIC|CLEAR)

| off | field |
|----:|---|
| +0  | ln_Succ |
| +4  | ln_Pred |
| +8  | data0 (v0) — returned by Pop, a0 of prelude@-60 |
| +12 | data1 (v1) — d0 of prelude@-60 |
| +16 | word flag: 0=pending, 1=notified |

## prelude.library internals referenced

| expr | meaning |
|---|---|
| `prelude+20/+22` | version/revision (Create gate: fail iff 5.x && rev<2) |
| `*(prelude+0x38)+0x15` bit0 | feature gate checked by Create |
| `*(prelude+0x8e)+0x10` ULONG | shared flag/depth: Pop gate, Append trigger, cleared by Create/Drain |

## External calls

- Exec: OpenLibrary -552, CloseLibrary -414, MakeLibrary -84,
  AddLibrary -396, Remove -252, RemHead -258, AddTail -246,
  FreeMem -210, AllocVec -684, FreeVec -690.
- DOS (data+0x96): Delay -198.
- prelude (data+0x114): -36, -60, -84, -90.
