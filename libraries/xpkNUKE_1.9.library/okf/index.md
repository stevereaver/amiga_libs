# xpkNUKE_1.9.library — OKF index

- Binary: `binary/xpkNUKE_1.9.library` (2,468 bytes, single 3E9 code
  hunk of 2,344; md5 `07c317d397b2b2c02945cf034c89225a`)
- Identity: `$VER: xpkNUKE 1.9 (05.08.2011)`; short name `NUKE`,
  "A relatively efficient packer that unpacks very quickly" (flags 9)
- Kind: XPK sublibrary — packer + unpacker, pack-mode "normal"
  (modetab entry at code+0xf6: pack 0x35c, unpack 0x276, 0x1c6 bytes
  of mode flags). Ten vectors, standard xpk sublib shape.
- CPU: plain 68000; no AttnFlags gate in LibInit.
- Reconstruction: `source/xpkNUKE.c` (all four real functions),
  `source/xpkNUKE_lib.s` (RomTag, inittab, lifecycle asm — lib base
  arrives in a6), `source/genfunctab.py` + `functab_stub.s` +
  `tail.s` (two-pass word-offset functab); built `-m68000`.
- Oracle: `work/oracle.py` (machine68k) — lifecycle, PackerInfo
  descriptor, 20-corpus pack streams byte-identical to the original,
  plus unpack round-trips, PackFree/realloc paths, tiny-outbuf error.

## Layout of this bundle

- `structures/layout.md` — lib base + workspace map + XpkSubParams use
- `functions/vectors.md` — vector map, entry/exit behaviour per LVO
- `algorithms/codec.md` — NUKE stream format, hash chains, emit order
- `findings/quirks.md` — original defects/limitations reproduced
- `log.md` — chronological work log
