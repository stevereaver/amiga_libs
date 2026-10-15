# ksort.library — memory layout

## Hunks

| # | Type | Size | File body | Contents |
|---|------|------|-----------|----------|
| 0 | CODE | 536  | 0x2c      | front end (below)     |
| 1 | BSS  | 64   | —         | static block          |
| 2 | CODE | 1400 | 0x324     | 7 wrappers + 7 workers + jmp stub |
| 3 | CODE | 60   | 0x8bc     | stricmp comparator    |

hunk0 relocs: 20 self + 15→hunk1 + 7→hunk2.  hunk2: 1→hunk3
(the `jmp` tail stub at h2+0x570).

## hunk0 map

```
0x00  moveq #0,d0; rts           entry stub
0x04  RomTag 4afc, matchw=+4, endskip=+0x7c,
      RTF_AUTOINIT, ver 34, NT_LIBRARY, pri 1
0x1e  "ksort.library"
0x2c  "ksort.library 34.1 (01 Jan 93)\r\n"
0x4d  "dos.library"  0x59 "intuition.library"  0x6b "graphics.library"
0x7c  InitTable { dataSize=0x2a, functab=+0x8c,
                  datatab=+0xbc, initfn=+0xdc }
0x8c  functab — 11 absolute-long entries + -1
0xbc  datatab — type9/name/flags6/ver34/rev1/idstr
0xdc  LibInit      (open 3 libs, store SysBase/seglist)
0x150 LibOpen      0x15e LibClose    0x172 LibExpunge
0x214 null stub    (the -24 vector)
```

## Library data area (PosSize 0x2a)

```
+0x20  UWORD OpenCnt            (managed by Open/Close)
+0x22  APTR  seglist            (written by LibInit)
+0x26  APTR  SysBase            (written by LibInit)
```

## BSS block (hunk1, 64 bytes)

The statics are accessed in the original through `a4`
(SAS/C small-data base) in LibInit and absolute `lea`/relocated
operands in LibExpunge:

```
+0x00  SysBase        written once by LibInit
+0x04  DOSBase        OpenLibrary result (unused)
+0x08  IntuitionBase  OpenLibrary result (unused)
+0x0c  GfxBase        OpenLibrary result (unused)
+0x10..+0x3f          zero, unused
```

LibExpunge OVERWRITES +4/+8/+0x0c with each CloseLibrary
residual, and (intended, but unrelocated) writes the seglist
at operand `00000000` — which lands at absolute address 0.
