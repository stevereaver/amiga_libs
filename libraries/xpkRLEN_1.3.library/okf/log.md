# Work log

- Parsed hunk structure: two hunks (CODE 0x2a0 + DATA 0x84)
- Mapped RomTag (AUTOINIT, ver 1), InitTable (dataSize 0x22),
  absolute-longword functab (10 vectors + -1), InitStruct stream
- Identified seglist code-slot at hunk+0x7a (no room in the base)
- Mapped hunk1 descriptors: XpkMode@+0x00, XpkInfo@+0x2a with
  cross-hunk string relocations
- Disassembled Open/Close/Expunge/Init: textbook pattern plus
  dead user-hook bsr's to a shared moveq#0/rts stub
- Decoded encoder: PackBits RLE, literal cap 127, run 3..127,
  output bound OutBuf+OutBufLen, `cmpiw`-hidden loop ops
- Found OOB defect: unconditional src[0..2] probe; false boundary
  run → unbounded over-read/over-write (Plane card filed)
- C reconstruction: framework + codec in xpkRLEN.c, resident/data
  hunks in xpkRLEN_lib.s; builds clean
- Host-verified: 60k+ round-trips pass, -17 on expansion

## 2026-10-15 — verbatim asm rebuild, byte + runtime identical

- Rewrote the reconstruction as hand asm `source/xpkRLEN_h0.s`
  (two hunks: `.text` code + `.data` descriptors); GNU ld output
  is byte-identical after `fixup.py` reorders the RELOC32 groups
  to the shipped binary's scrambled order (ascending sub-runs,
  each reversed, groups back-to-front — 21 hunk0 + 3 hunk1).
- md5 91531faa9caaff395ba3b5bbdd7996c2 == shipped binary.
- machine68k oracle verifies: AUTOINIT header fields, absolute
  functab (10 vectors), XpkInfo at DATA+0x2a / XpkMode at DATA+0
  via the second reloc group, codec round-trip, zero-length and
  incompressible edges, deferred + real expunge paths.
- NEW DEFECT FOUND: LibExpunge's deferred path does
  `bset #3,a6@(0xe)` after `a6` is reloaded with SysBase —
  DELEXP lands on execbase+0xe, never on lib_Flags, so Close can
  never perform a deferred expunge (see findings/
  DeferredExpungeDefect.md).  Verified: expunge@cnt=1 sets
  SYSB+0xe=0x08, lib flags unchanged; close->0 expunges nothing.
- Init stores the seglist in a code-space cell at hunk+0x7a;
  Expunge reads it back via `movel pc@(-0x62),d2`.
