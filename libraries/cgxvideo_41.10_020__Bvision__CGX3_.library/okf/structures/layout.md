---
file: layout
---
# cgxvideo 41.10 (020) layout

File 6280B, 4 hunks (all MEMF_PUBLIC, sizes 0x88/9/0x4a0/0x20
longs in the header table).

- h0 CODE recsize 0x88 (544B @file 0x2c): `moveq #-1,d0;rts`
  + RomTag @+4 + name/id/$VER strings + InitTable @+0xc8 +
  functab @+0xd8 + InitStruct datatab @+0x118 + reserved stub
  @+0x138 + six CYBI blocks @+0x13c..+0x1fa.
  RELOC32: 12->h0, 19->h2.
- h1 DATA 9 longs (36B @file 0x2ec): +0x00 "OverlaySemaphore\0"
  (16B, also used as an exec semaphore name — initfn
  InitSemaphore's lib+0x80), then patch table at +0x12 of
  {s16 lvo, u32 stubptr}: {-0xb4, h0+0x1e6}, {-0xa8, h0+0x20c},
  {0} term. RELOC32: 2->h0 (@+0x14,+0x1a).
- h2 CODE recsize 0x4a0 (4736B @file 0x334): main code —
  dep-name strings @+0x5e..+0xe4 (expansion/dos/utility/
  intuition/layers/graphics/cgxsystem/cybergraphics.library),
  initfn @+0xea, Open @+0x13c, Close @+0x2e2, Expunge @+0x2f4,
  CYBI handlers +0x304/+0x39c/+0x434/+0x51c/+0x5d8/+0x688,
  LF0..LF7 @+0x728/+0xace/+0xda4/+0xfb2/+0x1042/+0x110e/
  +0x10d4/+0x1148; tail JMP h3+0x44 (_kprintf) @+0x516.
  RELOC32: 15->h1, 1->h3.
- h3 CODE recsize 0x20 (128B @file 0x1618): kprintf debug stub
  (KPutCh/KPutStr/KPutFmt/KGetChar/KMayGetChar/KDoFmt/KPrintF);
  tail is HUNK_SYMBOL (0x3f0) — 29 symbol records, no relocs.

Lib base (dsize 0xbc, built by InitStruct dtab @h0+0x118:
type 9 @+8, flags 6 @+0xe, ver 41 @+0x14, rev 10 @+0x16,
name/id ptrs): +0x20 opencnt(w), +0x22 SysBase, +0x26 seglist,
+0x2a opened-flag(w), +0x2c utility, +0x30 intuition, +0x34
layers, +0x38 graphics, +0x3c cybergraphics, +0x40 cgxsystem,
+0x44 dos, +0x80 SignalSemaphore (InitSemaphore -558 in
initfn), +0xae MinList of driver objects.

Per-object struct (alloc'd by LF0, freed by LF1): +0xe layer
ptr, +0x14 ?, +0x26 flags(b, bit2 = "use defaults"), +0x2a
LayerHook, +0x32 driver-method lib base (jsr -156 = method
dispatch with tagpairs 0xb02..0xb06 / 0x80090007/0x80090009),
+0x36/0x37/0x38 param bytes, +0x3a..0x46 config longs,
+0x56/0x5a attrs, +0x61 flag byte (bit0 = attrs valid, bit1 =
hook armed), +0x62 armed word, +0x68 object-own dep, +0x7a ?
('CYBI'-era fields partially unidentified).

CYBI descriptor (18B, precedes each 20B forwarder stub):
'CYBI' magic, +4 min-version word (0x0027 = 39), +6..+0x11
zeros. Stub: movem.l a3,-(sp); lea desc(pc),a3; jsr h2-func;
movem.l (sp)+,a3; rts.
