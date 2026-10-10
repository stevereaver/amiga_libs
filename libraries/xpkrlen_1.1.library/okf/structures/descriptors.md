---
type: Structure
title: xpkRLEN template / descriptors
---

# DATA-hunk template (276B -> copied to base+58)

```
0x00  long 0                    copy marker
0x04  InitTable                 dataSize=0x13a, FUNCTABLE,
                                dataTable=0, INITFUNCTION
0x14  "$VER: RLEN 1.1 (Nov  2 1992)\0"
0x32  XpkMode node (42B)        next=0 upto=100 flags=1
                                packmem=0 unpackmem=0
                                packspeed=140 unpackspeed=1043
                                ratio=45 chunksize=0
                                desc[10]="normal"
0x52  "normal" is inline desc[10] above (0x52-0x5b)
0x5c  "RLEN"                    xi_Name
0x62  "Run Length 1.0"          xi_LongName
0x72  "Fast and simple compression usable for simple data"
0xa6  XpkInfo                   ver{1,0,0,0} + ptrs
0x100 reloc list                count=4, {0xe2,0xb6,0xb2,0xae}
```

## XpkInfo at template 0xa6 (base+224)

| off | field | value |
|-----|-------|-------|
| +0  | ver words | 1,0,0,0 |
| +8  | xi_Name | ->0x5c "RLEN" |
| +12 | xi_LongName | ->0x62 "Run Length 1.0" |
| +16 | xi_Description | ->0x72 "Fast and simple..." |
| +20 | xi_ID | 'RLEN' |
| +24 | xi_Flags | 9 |
| +28 | xi_MaxPkInChunk | 0x7d00 (32000) |
| +32 | xi_MinPkInChunk | 0 |
| +36 | xi_DefPkInChunk | 0x7d00 |
| +40 | xi_PackMsg | 0 |
| +44 | xi_UnpackMsg | 0 |
| +48 | xi_PackedMsg | 0 |
| +52 | xi_UnpackedMsg | 0 |
| +56 | xi_DefMode | 50 |
| +60 | xi_ModeDesc | ->0x32 mode node |

## Reloc list (data+0x100)

`{4, 0xe2, 0xb6, 0xb2, 0xae}` — the four pointer fields in
the XpkInfo get `base+58` added by INITFUNCTION.
