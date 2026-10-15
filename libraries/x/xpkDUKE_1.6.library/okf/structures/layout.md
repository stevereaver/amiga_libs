# Data layouts

## Amiga hunk (file format)

```
+0x000 0000_03f3  HUNK_HEADER
+0x004 0           (no resident names)
+0x008 0000_0002  hunk table size = 2
+0x00c 0000_0000  first hunk = 0
+0x010 0000_0001  last hunk = 1
+0x014 0000_02dc  hunk0 mem size = 732 longs = 2928 bytes
+0x018 0000_0021  hunk1 mem size = 33 longs  = 132 bytes
+0x01c 0000_03e9  HUNK_CODE
+0x020 0000_02dc  code size (longs)
+0x024 ...        code body, 2928 bytes (file 0x24..0xb93)
+0xb94 0000_03ec  HUNK_RELOC32: 21 hunk0 refs + 1 hunk1 ref (@0x988)
+0xc04 0000_03f2  HUNK_END
+0xc08 0000_03ea  HUNK_DATA, 0x21 longs = 132 bytes
+0xc94 0000_03ec  HUNK_RELOC32: 7 hunk0 refs + 1 hunk1 ref (@0x66)
+0xccc 0000_03f2  HUNK_END   (file ends 0xcd0)
```

Code begins `70 ff 4e 75` (`moveq #-1,d0; rts` — the -1 return is
a 1.x-generation detail) with the `4a fc` RomTag at code+4.

## Code map (offsets into the CODE hunk body)

| range      | contents |
|------------|----------|
| 0x000      | entry stub `moveq #-1,d0; rts` (unreferenced) |
| 0x004      | RomTag: EndSkip→0x106, name→0x108, id→0x118, init→0x1e |
| 0x01e      | InitTable: dataSize 0x22, functab@0x2e, datatab@0x5a, LibInit@0x7e |
| 0x02e      | functab: 10 longword vectors + 0xffffffff |
| 0x05a      | datatab (InitStruct): ln_Type/Name, lib_Flags=6, ver1 rev6, idstr |
| 0x076–0x7d | gap: word pad + **seglist cell at 0x7a** (self-modifying) |
| 0x07e      | LibInit: stores seglist at code+0x7a, dead `bsr 0x134` check |
| 0x09e      | Open |
| 0x0ac      | Close |
| 0x0c0      | Expunge (reads seglist PC-relative from code+0x7a) |
| 0x104      | -24 null stub `moveq #0,d0; rts`; EndSkip=0x106 |
| 0x108      | "xpkDUKE.library" |
| 0x118      | "xpkDUKE 1.6 (08.06.1997)\r\n" |
| 0x134      | -48 null stub (also LibInit/Expunge's dead bsr target) |
| 0x138      | seltab {0,0,4,10} |
| 0x140      | class thresholds (16 words, len≤1/len2/len≥3 lists) |
| 0x160      | encoder residual-bit counts (16 words) |
| 0x180      | class code nibbles 0..15 (identity) |
| 0x1a0      | decoder nbtab (16 words) |
| 0x1c0      | decoder basetab (16 words) |
| 0x1e0      | decoder copytab/jump offsets {0x20×4, 0x1e×6, 0×6} |
| 0x200      | flush_lit subroutine |
| 0x2fa      | pack core (calls init 0x60e, finish 0x696, writeback 0x6fa) |
| 0x73c      | decoder (entry regs: a1=inbuf!, a4=inbuf+inlen, a0=scratch, a2=scratch+outlen) |
| 0x848      | delta-encode (Duff device, dead `cmpil #8` check) |
| 0x8d2      | "DUKE" / "Duke" / "NUKE with a delta preprocessor" / "Duking" / "Unduking" / "Duked" / "Unduked" |
| 0x91e      | integrate (Duff device, dead `cmpil #8` check) |
| 0x986      | XpksPackerInfo (`lea` DATA+0x2a) |
| 0x990      | XpksPackFree |
| 0x9f6      | pack workspace alloc sub (4 allocs + cleanup via PackFree) |
| 0xa58      | XpksPackChunk |
| 0xae2      | XpksUnpackChunk |
| 0xb3c      | XpksUnpackFree |
| 0xb62      | nop pad |
| 0xb64      | memset subroutine (backward dbf fill) |
| 0xb70      | end (= hunk size) |

## DATA hunk (132 bytes)

| range      | contents |
|------------|----------|
| 0x00–0x27  | XpkMode "normal": Next=0, Upto=100, Flags=1, PackMemory=0x3805c, UnpackMemory=0x8000, PackSpeed=0x24, UnpackSpeed=0x276, Ratio=0x1c6, ChunkSize=0 |
| 0x28       | word 0 pad (sic — XpkInfo starts at 0x2a) |
| 0x2a       | XpkInfo (88 bytes): ver words {1,1,0,1}, Name→"DUKE", LongName→"Duke", Desc→"NUKE with a delta preprocessor", ID 'DUKE', Flags=9, MaxPkInChunk 0x7530, **MinPkInChunk 10**, DefPkInChunk 0x7530, msgs "Duking"/"Unduking"/"Duked"/"Unduked", **DefMode 50**, pad, ModeDesc→+0 |
| 0x82–0x83  | trailing pad |

## XpkSubParams (a0 on entry)

| off | field |
|-----|-------|
| +0  | InBuf |
| +4  | InLen |
| +8  | OutBuf |
| +12 | OutBufLen |
| +16 | OutLen (pack result / unpack expected length) |
| +52 | Sub[0] = 92-byte work header (pack side) |
| +56 | Sub[1] = 0x8000 scratch — pack: delta'd input; unpack: decode target |

## Memory plan (four separate AllocMem blocks)

| block | size | flags | where |
|-------|------|-------|-------|
| work header | 92 | MEMF_CLEAR (0x10000) | xsp_Sub[0] |
| tab1 | 0x20000 | MEMF_ANY | work+8 |
| tab2 | 0x10000 | MEMF_ANY | work+12 |
| scratch | 0x8000 | MEMF_ANY | xsp_Sub[1] |

xm_PackMemory = 0x3805c = 92 + 0x20000 + 0x10000 + 0x8000 exactly;
xm_UnpackMemory = 0x8000 (the scratch alone). tab1/tab2 are
re-cleared byte-wise on every PackChunk call (two memset calls:
0x20000 and 0x10000 bytes).

## Work header (a4 in the core, == xsp_Sub[0])

| off | field |
|-----|-------|
| +0  | src pointer = xsp_Sub[1] (the delta'd input) |
| +4  | dst = OutBuf |
| +8  | tab1 = separate 0x20000 block (pair→pos heads, 64K words) |
| +12 | tab2 = separate 0x10000 block (pos→prev chain, 32K words) |
| +16 | outcur — next stream slot |
| +20 | litptr — literal write ptr (grows backward from dst+sext(outmax)) |
| +24 | srcend = src + inlen |
| +28 | tab2 lazy-clear frontier |
| +32 (w) | inlen |
| +34 (w) | outmax = OutBufLen-4 |
| +36 (w) | lastpos = inlen-1 |
| +38 (w) | litstart |
| +40 (s) | litcnt-1 (init -1) |
| +42 (w) | window = 0x6a8f (written as `movew #0x6a90` then `subqw #1`) |
| +44..+63 | ctr1..4 (words) + acc1..4 |
| +64..+79 | ptr1..4 (pending stream slots; start = +80 scratch) |
| +80..+91 | scratch — each stream's first flush lands here (discarded) |
