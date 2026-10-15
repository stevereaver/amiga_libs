---
file: layout
---
# cgxvideo 41.12 (020) layout

File 6268 B, 4 hunks. Hunk table: sizes 0x87/0x09/0x49e/
0x20 longs.

| # | type | body | contents |
|---|------|------|----------|
| 0 | CODE | 0x21c | `moveq #-1,rts` stub; RomTag @+4 (AUTOINIT 0x80, ver 41, EndSkip->h2+0x1278); name "cgxvideo.library" @+0x1e; id `"cgxvideo.library 41.12 (4.8.99) \r\n"` @+0x30; "$VER: cgxvideo.library 41.12 (4.8.99) 68020 Version " + copyright @+0x5c; InitTable @+0xc4; functab 15 abs-longs @+0xd4; datatab @+0x114; ExtFunc stub @+0x134; 6 CYBI records @+0x138..0x21b |
| 1 | DATA | 0x24 | "OverlaySemaphore\0" @+0; patchtab @+0x12: `{0xff4c(-180),->h0+0x1e2},{0xff58(-168),->h0+0x208},{0}` |
| 2 | CODE | 0x1278 | patcher @+0; dep-name strings @+0x60-0xe8 (expansion/dos/utility/intuition/layers/graphics/cgxsystem/cybergraphics); initfn @+0xea; Open @+0x13c; Close @+0x2e2; Expunge @+0x2f4; hook impls @+0x304/0x39c/0x434/0x51c/0x5d8/0x688; vlayer refresh @+0xb38; 8 API funcs @+0x728/0xace/0xda4/0xfa8/0x1038/0x10ca/0x1104/0x113e; debug strings "ActivateWindow wnd %08lx\n" @+0x4da, "VLayer window frame refresh !\n" @+0x4f4; KPrintF jump @+0x514 -> h3+0x44 |
| 3 | CODE | 0x80 | serial debug helpers; HUNK_SYMBOL tail: _KPutCh, KPutChar, _KPutS, KPutStr, ps1, KGetChar, KMayGetChar, _KPutFmt, _KPrintF, KPrintF, KDoFmt, _KDoFmt (+ps0) |

Relocs (RELOC32):
- h0->h0 {6,12,16,1a,c8,cc,e0,104,108,10c,11a,12c}
  (RomTag name/id/init, InitTable ft/dt, functab->h0
  entries x4, datatab name/idstr values)
- h0->h2 {a,d0,d4..104 except e0, 154,17a,1a0,1c6,1ec,
  212} (EndSkip, initfn, 12 functab->h2 entries, 6 CYBI
  jsr targets)
- h1->h0 {14,1a} (the two patchtab newfunc longs)
- h2->h1 {c,f6,146,532,5ea,738,ada,b4a,cd8,db2,fb6,1048,
  10d6,1110,114c} (a4-relative refs into DATA hunk:
  patchtab + OverlaySemaphore name)
- h2->h3 {516} (jmp _KPrintF)

## InitTable (h0+0xc4)

`{dsize 0xbc, functab->h0+0xd4, datatab->h0+0x114,
initfn->h2+0xea}`; functab = 15 abs-longs + -1 term.

datatab ops: initbyte +8=9 (NT_LIBRARY), initlong +10=
name, initbyte +14=6 (LIBF_CHANGED|LIBF_SUMUSED),
initword +20=41/+22=12, initlong +24=idstr.

## Library base (dsize 0xbc)

| off | field |
|-----|-------|
| 0x00-0x21 | struct Library via datatab |
| +34 | exec base (initfn a6) |
| +38 | seglist (initfn a0) |
| +42 | w: deps-opened/patches-installed flag |
| +44 | utility.library v39 |
| +48 | intuition.library v39 |
| +52 | layers.library v39 (CYBI patch target) |
| +56 | graphics.library v39 |
| +60 | cybergraphics.library (FindResident, not OpenLibrary) |
| +64 | cgxsystem.library v41 |
| +68 | dos.library v39 |
| +128 | SignalSemaphore "OverlaySemaphore" (InitSemaphore in initfn) |
| +174 | MinList of VLayerHandles (NewList in initfn) |

expansion.library v39 handle is opened at first Open,
kept in a2 only — never stored, never closed (anchor or
leak; see findings).

## VLayerHandle fields observed

+14 Window*, +42 ?, +50 driver lib base, +54 attr cache,
+58/62/66/70 indents, +86 VOA_ColorKeyPen, +90
VOA_ColorKey, +97 flag byte (bit0 colorkey-valid, bit1
backfill hook), +98 w attached, +104 driver object.
