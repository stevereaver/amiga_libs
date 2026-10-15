# xpkSQSH_1.00.library — OKF index

- Binary: `binary/xpkSQSH_1.00.library` (2,232 bytes, single 3E9 hunk of
  2,100 bytes code)
- Identity: `xpkSQSH 1.00 (13.10.93)` by John Hendrikx
- Kind: XPK sublibrary, "LZ based cruncher; special algorithms for
  8 bit sound data; fast decrunching" (ID `SQSH`, lib flags 6 / node
  type 9, version 1.0)
- CPU: uses 68020 bitfield ops (`bfins`/`bfextu`/`bfffo`) but, unlike
  the 1.2 siblings, has **no** AttnFlags gate — crashes on plain 68000.
- Reconstruction: `source/xpkSQSH.c` (codec + lifecycle),
  `source/xpkSQSH_lib.s` (RomTag/inittab/datatab/absolute-long functab/
  LibInit/stubs/strings), built `-O2 -fno-strict-aliasing -m68020`.
- 1.00-vs-1.2 deltas: absolute-longword functab (10 entries) instead
  of word-offset; LibInit builds the XpkInfo + XpkMode descriptor into
  library private data at run time (dataSize 0xa8) instead of a static
  datatab; no 020 gate; -42/-48/-60 are bare `rts` (1.2 has
  PackFree/UnpackFree there).
- Verification (machine68k, M68020): all 16 sweep inputs produce
  **byte-identical** pack streams vs the original (incl. `-17`
  rejections on 5 short inputs); every stream round-trips through the
  reconstruction's own decoder, and original streams decode correctly.
  LibOpen/Close/Expunge/PackerInfo verified under the oracle.

Algorithm: LZ + signed-delta literals specialised for 8-bit sound,
same family as the 1.2 sibling. Hash = `(in[p]<<4)^in[p+1]` & 0xfff;
two-slot per-position chain at workmem+0x2080 chooses a child by the
sign of the first mismatched byte; match length capped at 47. Once
"literal pressure" exceeds 7 (litpress>=8) the literal/match marker
sense inverts: literals emit ladder-tagged narrow-width delta runs
and matches take a '00' prefix. Encoder and decoder agree on the
>=8 threshold — the original `bhi`/`bls` mnemonic pair (0x62/0x63)
is *strictly-greater*, not higher-or-same.

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.
