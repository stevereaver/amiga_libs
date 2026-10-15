# PowerPacker_37.7_020__(23.07.01).library

"$VER:pplib 37.8 020+ (23.7.01)" (dir/version named 37.7) —
PowerPacker compression library, 020+ build. 5888B.

- Flat single CODE hunk (0x5a9 longs), AUTOINIT, RELOC32 tail
  (10 slots ->h0).
- Resident @h0+4 (26B extended, ver 37); name->h0+0x5c,
  id->h0+0x75, init->h0+0x4c.
- InitTable: dsize 0x28, ftab@h0+0x1d4 (word-offset table: ffff
  marker + 23 signed entries, first 4 negative), dtab@h0+0x1e,
  initfn@h0+0xc0.
- Deps: dos, intuition, graphics (+ reqtools.library for error
  requesters); messages: "encrypted file", "incorrect password",
  "unknown PP data header", "empty file".
