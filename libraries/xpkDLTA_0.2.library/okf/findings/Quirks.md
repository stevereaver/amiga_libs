---
type: Finding
title: Quirks in xpkDLTA 0.2
---

# Quirks

- **Codec off-by-one.**  Both codec loops are `subq.w #1,d1 / bcc`
  do-while loops that exit on borrow from 0 — they run InLen bodies,
  not InLen-1, so **one byte past InLen is read and written** while
  xsp_OutLen reports only InLen.  Verified on the shipped binary under
  machine68k (a 25-byte chunk produced 26 output bytes; the stored
  carry low byte was the byte past the input).  The off-by-one is
  symmetric so pack→unpack still round-trips.
- **InLen == 0 overflows.**  Same loop turns a zero-length chunk into
  a 64K-byte write (plus the unconditional first byte) — do not feed
  it empty chunks.
- **Descriptors live in the library base.**  dataSize is 0xfc;
  InitStruct writes the whole XpkInfo at base+0x26 (including offsets
  0x82/0x9e/0xa2 = flat byte offsets >0x7f, no extension) and
  LibInit links xi_ModeDesc (base+0x62) to the XpkMode at base+0x7e.
- **Null vectors reuse pack's epilogue.**  LVOs -24/-42/-48/-60 encode
  the shared `moveq #0,d0/rts` at code+0x20a — inside XpksPackChunk —
  not the entry stub at code+0.
- **Cross-function epilogue sharing.**  Pack's two error exits
  (-10/-11) `bra.s` FORWARD into UnpackChunk's `movea.l (sp)+,a2/rts`
  at code+0x252 — valid only because both push a2 at entry.
- **xi_Flags = 0x2000** — only XPKIF_ENCRYPTION; PK_CHUNK/UP_CHUNK are
  missing even though both codecs exist (fixed in 0.3 → 0x2009).
- **Descending reloc32 tail** — the 17 offsets are stored
  high-to-low; reproduced by `source/fixup.py`.
- **No $VER cookie** — id string is plain `xpkDLTA.library v0.2`.
- **Carry is a dirty longword**: `xsp_Sub[1]` is loaded/stored as a
  full long whose upper bytes keep whatever d0 held on entry; only
  the low byte is meaningful.
