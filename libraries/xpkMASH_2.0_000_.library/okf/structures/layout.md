# Structures — xpkMASH 2.0(000)

## XpkSubParams (a0 on entry; offsets used by the code)

| off | size | field | use |
|-----|------|-------|-----|
| 0x00 | 4 | xsp_InBuf | source |
| 0x04 | 4 | xsp_InLen | source length |
| 0x08 | 4 | xsp_OutBuf | dest |
| 0x10 | 4 | xsp_OutLen | pack: written packed size; unpack: expected outlen |
| 0x34 | 4 | xsp_Work | cached work allocation (PackChunk lazily allocs) |
| 0x38 | 4 | xsp_WorkSize | alloc size, read back by PackFree |
| 0x3c | 4 | xsp_Bound | overwritten by pack: `OutBuf + InLen - 10` |
| 0x40 | 4 | xsp_Tries | overwritten by pack: 1024 (chain budget seed) |

## Library data (dataSize 38)

Std `struct Library` (34 bytes) + `seglist` long at base+34.
Nothing else — no exec pointer field, all exec calls go
through `moveal 4,a0/a6` (abs SysBase).

## Work allocation (one block: `0x20000 + 2*inlen`)

| region | size | contents |
|--------|------|----------|
| wk+0 | 0x20000 | `head[65536]` UWORD — rolling 16-bit pair-key table (pass1); later overwritten by the pass2 record stream |
| wk+0x20000 | 2*inlen | `gaps[inlen]` WORD — gap[i] = distance from the byte pair at i to its previous occurrence (or -1) |

Pass2 writes the record stream at wk+0 — 6-byte records
`{pos.w, dist.w, len-2.w}` (all stores land on even
addresses; the 020-only features are the scaled-index
addressing modes and the AFB_68020 LibInit gate).  Once the
record stream exceeds 0x20000 bytes it overlaps the
still-live gap array (defect).

## XpkInfo descriptor (code+0x6de; returned by LVO -30)

`{xpkinfo_ver=1, libver=2, masterver=2, modesver=0}`
(words), Name "Mashiner", LongName "Mashiner V2.0",
Description "WindowSize: 32KB, 2 mixed streams",
ID 'MASH', Flags(long) 9, MaxPkInChunk 0x10000,
MinPkInChunk 0, DefPkInChunk 0x10000,
msgs Mashing/UnMashing/Mashed/UnMashed,
DefMode 100, ModeDesc → one record:

```
next 0 | upto 100 | flags 1 | packmem 0x00040010
unpackmem 0 | packspeed 7 | unpackspeed 120
ratio 473 (w) | chunk 0 (w) | name " -->" (pad to 10)
```

All string pointers and xi_ModeDesc are code offsets
patched by the hunk relocations.
