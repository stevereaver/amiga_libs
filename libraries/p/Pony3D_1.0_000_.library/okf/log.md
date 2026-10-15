# Pony3D.library 1.0(000) — work log

- Parsed hunks: CODE 0x3a8 + DATA 0x4cc; RomTag AUTOINIT(0x80)
  v1 pri0 at h0+0xc6; InitTable dataSize=0x2a, functab→+0x17e
  (8 absolute-long entries + -1), datatab→+0x1a2, init→+0x1c2.
- Bootstrap at h0+0 is a CLI entry: OldOpenLibrary/OpenLibrary
  "reqtools.library" v38 → alloc request via -30(1,0), init
  fields {+0=1, +12=title "Pony3D.library", bset#2 @+16},
  display via -66(win=0, body=credits text, gad="OKAY", obj,
  tags=0), free via -36, CloseLibrary → d0=20.
- dos fallback at +0x88 (no reqtools, or alloc fail after
  closing it): Output() → Write(stdout, idstr, *(h0+0x16a)=119)
  → CloseLibrary → d0=20.  QUIRK: fallback never restores the
  14 saved registers — wild rts through the stale stack.
- datatab: `a0 0c 09` = byte@12=9 — dead write inside ln_Name
  (clobbered by following `80 0a` long@10); ln_Type never set
  (stays 0); flags=6, ver=1, rev=0.
- LibInit stores seglist→lib+38, SysBase→lib+34; the trailing
  `braw +2` SKIPS the a5 restore → 4-byte stack leak (quirk).
- Lifecycle standard: opencnt@32, DELEXP bit3@14, correct
  expunge via lib+34 SysBase + lib+38 seglist.
- API mapped: -30 RotatePoints (Euler XYZ pairs (y,z),(x,z),
  (x,y); 8.8 fixed via hunk1 trig table; angles +2 mod 512),
  -36 TranslatePoints, -42 ProjectPoints (cx,cy halved INSIDE
  the per-vertex loop incl. divsw remainder accumulation;
  z==0→+1), -48 Plot (y*40+x/8 byte, bit (~x)&7).
- Trig table @ h1+0xa6: 512 words ≈ -sin(i·2π/256)·256 for
  i<256, cos(i·2π/256)·256 for i≥256 — embedded verbatim
  (ASM-One generator rounding, ±1 vs exact).
- All list loops are dbf-bound on the count word → count+1
  elements processed.
- Reconstruction: `source/pony3d.c` (4 fns, mulsw/divsw inline
  helpers for exact 16x16→32 and quot+rem semantics,
  DBFLOOP macro) + `source/pony3d_lib.s` (CLI bootstrap,
  RomTag, InitTable, lifecycle).
- Built 3500-byte CODE+DATA library; machine68k oracle:
  byte-identical on directed battery + 120-case random sweep
  + both CLI paths (object fields, call sequence, 119-byte
  Write, RETURN_ERROR).
