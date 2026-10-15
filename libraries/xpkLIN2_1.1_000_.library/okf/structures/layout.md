# Data layouts

## Amiga hunk (file format, 3152 bytes)

```
+0x00  0000_03f3  HUNK_HEADER
+0x04  0           (no resident names)
+0x08  0000_0001  hunk table size
+0x0c  0000_0000  first hunk = 0
+0x10  0000_0000  last hunk = 0
+0x14  0000_02f2  hunk 0 size = 754 longs = 3016 bytes
+0x18  0000_03e9  HUNK_CODE
+0x1c  0000_02f2  code size
+0x20  ... code body, 3016 bytes
+0xbe8 0000_03ec  HUNK_RELOC32, 21 offsets for hunk 0:
        0x6 0x12 0x16 0x1a   (RomTag: matchtag/name/idstr/init)
        0x68 0x6c 0x70       (InitTable: functab/datatab/initfn)
        0x7a 0x8c            (datatab: ln_Name, idstring longs)
        0x562 0x692          (lea.l abs-long code refs, jump-table loop entries)
        0xaa8 0xaac 0xab0 0xac8 0xacc 0xad0 0xad4 0xadc
                             (XpkInfo pointers)
        0xaf8 0xb22          (xm_Next chain links)
+0xc48 (reloc terminator 0)
+0xc4c 0000_03f2  HUNK_END
EOF @0xc50
```

## Code map (offsets into the hunk body)

| range      | contents |
|------------|----------|
| 0x000      | entry stub `moveq #0,d0; rts` — doubles as the null vector; "return 0" paths `bra.w`/`beq.w` here from far away |
| 0x004      | RomTag (matchtag=4, **endskip=0**, flags 0x80, ver 1, type 9, pri 0) |
| 0x01e      | "xpkLIN2.library\0" |
| 0x02e      | "$VER: xpkLIN2 V1.1 (1 Oct 2013) by Gerhard Tuenkler\r\n\0" (54 B) |
| 0x064      | InitTable: dataSize 0x26, functab@0x94, datatab@0x74, init@0xac |
| 0x074–0x093| datatab (InitStruct program) |
| 0x094–0x0ab| functab: `ffff`, 10 word offsets, `ffff` |
| 0x0ac–0x0b3| LibInit: `movea.l d0,a1; move.l a0,0x22(a1); rts` |
| 0x0b4      | LibOpen |
| 0x0c2      | LibClose (falls into 0x0d4) |
| 0x0d4      | LibExpunge (shared body 0x0e4: Remove + FreeMem) |
| 0x112      | XpkSubFree (shared PackFree/UnpackFree) |
| 0x132      | XpksPackerInfo |
| 0x13a–0x75b| XpksPackChunk (matcher, bit-packer, adaptive tables, trailer emit) |
| 0x75c–0xa73| XpksUnpackChunk |
| 0xa74–0xa9f| string-hash helper (password hash) |
| 0xaa0–0xaf7| XpkInfo block (88 bytes) |
| 0xaf8–0xb75| three XpkMode records (42 bytes each) |
| 0xb76–0xbc7| strings |

## Library-private layout

`dataSize = 0x26` (38): `struct Library` (34 bytes) +

| off | field |
|-----|-------|
| +0x22 | seglist (written by LibInit, read by Expunge) |

## XpkSubParams fields touched (a0 = xsp)

| off | field | use |
|-----|-------|-----|
| 0x00 | xsp_InBuf | input |
| 0x04 | xsp_InLen | input len |
| 0x08 | xsp_OutBuf | output |
| 0x0c | xsp_OutBufLen | (pack bound is OutBuf+InLen instead) |
| 0x10 | xsp_OutLen | pack: written; unpack: PRESET expected size |
| 0x1c | xsp_Mode | pack only, first call: <34 -> sub 5, <67 -> sub 6, else 7 |
| 0x20 | xsp_Password | STRPTR hashed into stream[0:4] (pack) / verified (unpack) |
| 0x34 | xsp_Sub[0] | workspace pointer (lazy alloc, shared pack/unpack) |
| 0x38 | xsp_Sub[1] | workspace size (0x4900/0x8900/0x10900 pack, 0x20 unpack) |
| 0x3f | (low byte of Sub[2]) | active submode 5/6/7 |
| 0x40 | xsp_Sub[3] | pwhash written into stream |

## Pack workspace (xsp_Sub[0], MEMF_PUBLIC)

Size by mode: `0x4900` (mode<34), `0x8900` (mode<67), `0x10900`
(mode>=67); submode byte 5/6/7 selects the hash shift.

| off | contents |
|-----|----------|
| +0x000..0x00f | mode/control area |
| +0x010..0x01f | distance-class bounds {0,2,6,14,30,62,126,254,510} + per-class bit counts (bytes 1..8 at +0x12..0x19) |
| +0x020..0x41f | 256-long byte frequency histogram |
| +0x100..0x10f | 16 code-length bytes copied into the stream trailer |
| +0x420.. | hash-head table, `0x100<<submode` word entries (sub7: 0x10000 B -> 0x420..0x103ff) |
| tail | zeroed each call by the movem clear-loop ((size>>8) x 252 B downward from buf+size) |

Unpack workspace: just 0x20 bytes (Sub[0]) — the 8-entry adaptive
bound table + counts; decode tables come from the stream trailer.

## XpkInfo @ code+0xaa0 (88 bytes)

```
01 01 02 00 | Name->"LINO2" | LongName->"Lino2 V1.1"
| Desc->"Better version of Lino1" | ID 'LIN2' | flags 0xa009
| MaxPkInChunk 0x7fffffff | MinPkInChunk 0 | DefPkInChunk 0x8000
| "Comressing" | "Expanding" | "Compressed" | "Expanded"
| DefMode 100 | pad | ModeDesc->0xaf8 | 6 reserved longs
```

## XpkMode records (42 B each)

| field | minimal @0xaf8 | normal @0xb22 | maximal @0xb4c |
|-------|----------------|---------------|----------------|
| xm_Next       | ->0xb22 | ->0xb4c | 0 |
| xm_Upto       | 33 | 66 | 100 |
| xm_Flags      | 1 | 1 | 1 |
| xm_PackMemory | 0x4900 | 0x8900 | 0x10900 |
| xm_UnpackMemory | 0x20 | 0x20 | 0x20 |
| xm_PackSpeed  | 80 | 88 | 94 |
| xm_UnpackSpeed | 179 | 179 | 179 |
| xm_Ratio (w)  | 409 | 413 | 415 |
| xm_MaxPacked (w) | 0 | 0 | 0 |
| name (10 B)   | "minimal" | "normal" | "maximal" |

The PackMemory values match the mode-select constants in
XpksPackChunk (0x4900/0x8900/0x10900) exactly.
