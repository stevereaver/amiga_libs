# xpkSQSH_1.2_000_.library — OKF index

- Binary: `binary/xpkSQSH_1.2(000).library` (2,700 bytes, single 3E9 hunk
  of 2,580; md5 909bfcd2fc2e5879ad52fd9f418dd8ee)
- Identity: `$VER: xpk V1.2 (1 Oct 2013) by John Hendrikx`
- Kind: XPK sublibrary, "LZ based cruncher, special algorithms for
  8 bit sound data, fast decrunching" (ID `SQSH`, flags 9)
- CPU: plain 68000 — no AttnFlags gate in LibInit; the codec uses no
  020 bitfield instructions (zero `bfins`/`bfextu`/`bfffo` opcodes in
  the hunk). Twin of `xpkSQSH_1.2(020)` — identical codec semantics,
  68020 vs 68000 codegen.
- Reconstruction: `source/xpkSQSH.c` (codec + lifecycle),
  `source/xpkSQSH_lib.s` (RomTag/inittab/datatab/descriptor/init),
  `source/genfunctab.py` + `functab_stub.s` (two-pass word-offset
  functab); built `-m68000`.
- Verification: all 16 corpus streams produced under machine68k are
  byte-identical to the original (the same corpus also matches the
  1.2(020) original bit-for-bit); every packable input round-trips
  through the library's own unpack; short/incompressible inputs fail
  with the original's -17. LibOpen/Close/Expunge lifecycle verified.

Algorithm: identical codec to the 020 build — see
`structures/layout.md` and the 020 sibling's bundle
(`../../xpkSQSH_1.2_020_.library/okf/structures/layout.md`) for the
full stream/token spec. 68000-specific build notes:

- 32-bit divides/multiplies become libcalls under `-m68000`; the
  reconstruction emits native `divu.w`/`mulu.w` via `divuw`/`muluw`
  asm helpers, and provides a `__mulsi3` stub for GCC's loop strength
  reduction (`p->bitpos += w` -> `w*run`), which cannot be expressed
  in C. The original carries the same libcall routines (its hunk is
  ~700 B larger than the 020's).
- Descriptor differences vs the 020 build: longname is "Squash V1.2"
  (not "Squash 020+ V1.2"), PackSpeed 0x0c, UnpackSpeed 0x3c.

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.
