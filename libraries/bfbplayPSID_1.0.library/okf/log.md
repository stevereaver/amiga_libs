# bfbplayPSID 1.0 RE log

- IRA pass resolved the LONG functab: 14 vectors, all decoded.
  bfb player-module template (same as bfbplayMED! done earlier):
  tag-driven InitModule wrapping playsid.library.
- Decode highlights: InitModule source chain filename ->
  pre-opened handle -> memory image+len; file size via
  Seek(END)+Seek(BEGIN) pair; session fields incl. the
  byte-write trick making cursong = startSong; GetInfo lazy
  {2,30,author,released} record; StopModule's odd A5 arg ABI.
- Reconstructed in C + AUTOINIT asm skeleton (absolute functab,
  verbatim datatab). Verified: header bytes identical modulo
  relocated pointers; datatab byte-exact; all 14 functab targets
  resolve to the right functions; per-function codegen reviewed
  against the disassembly (InitModule tag scans, double-Seek,
  alloc flags 0x10000/0x10001, playsid call sequence, a5-arg
  StopModule, clamp arithmetic in SetSubsong).
- GCC quirks handled: a5 param binding unsupported (explicit
  movel %a5 read in StopModule); packed unaligned LONGs emit
  byte-wise access (semantic superset of the shipped MOVE.L).
