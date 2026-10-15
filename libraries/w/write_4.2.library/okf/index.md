# write.library 4.2 — OKF index

Tim Teulings' `write.library` 4.2 (7.11.95) — a compiled-C ARexx/console
text-output library. Sends text to a "WRITE" message port (ARexx host) and
manages a console window via dos.library.

- binary: `binary/write_4.2.library` (2556 bytes, 3 hunks)
- source: `source/write_h0.s`, `write_h1.s`, `write_h2.s` — pure 68k asm
- build: `cd source && make` → byte-identical (md5 `0b4c797b31b85c4ece510e7ed70a2a0b`)
- oracle: `work/oracle.py` (machine68k) — lifecycle + all vectors traced,
  orig vs rebuild output identical
- plane: AMIGALIBS-150

## Layout

- hunk0 CODE 0x868: DOS stub + RomTag (AUTOINIT v4.2), init, Open/Close/
  Expunge, 4 API vectors, hook helpers, embedded strings, lib open/close
  helpers
- hunk1 CODE 0x40: absolute-long function table (8 vectors, `-1` term)
  + `write.library` name + `"Version 1.0"` idstr
- hunk2 DATA 0x54: pad long + InitTable (dsize 0xb0, ftab→h1, dtab=0,
  init→h0+0x20) + 60-byte runtime template copied to lib+0x3c on init

See `functions/vectors.md`, `structures/layout.md`, `findings/quirks.md`,
`log.md`.
