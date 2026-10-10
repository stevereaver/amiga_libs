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
