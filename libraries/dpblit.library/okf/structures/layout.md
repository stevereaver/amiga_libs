---
type: Structures
title: dpblit.library (DPBlitBase) layout
---

# Layout

- datasize 0x50 -> 34B node + 46B private area starting
  lib+0x22 (seglist) / lib+0x30 (hunk1 copy).
- lib+0x30..0x4b = verbatim copy of hunk1 longs 0..6 made by
  initfn's mid-instruction copy loop:
  +0x30=0, +0x34=datasize 0x50, +0x38=functab ptr (h3+0),
  +0x3c=0 (datatab), +0x40=initfn ptr (h0+0x20), +0x44=0 then
  overwritten with GfxBase, +0x48=0xdff000 chip-reg base.
- Blitter registers are written via a0=lib+0x48 ($dff000):
  BLTCON0+0x40, BLTCON1+0x42, AFW/ALW +0x44/0x46, CPT/BPT/APT/DPT
  +0x48..0x54, BLTSIZE +0x58, MODs +0x60..0x66, CDAT/BDAT/ADAT
  +0x70..0x74.
- hunk2 = 512B MEMF_CHIP data buffer used as blit pattern/
  texture; h0 code pokes it via absolute slots (lea/pea/clr.w).
- Mask table at h0+0x1a0: 17 words 0xffff>>n (n=0..16);
  'graphics.library' string at h0+0x1c2.
- hunk3: functab 7 longs + 0xffffffff @+0, 'dpblit.library'@+0x20,
  'DPBlitBase'@+0x30 (+ trailing 'l' byte @+0x3b).
