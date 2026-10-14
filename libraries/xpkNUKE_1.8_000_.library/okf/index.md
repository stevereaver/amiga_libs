# xpkNUKE_1.8_000_.library — OKF index

- Binary: `binary/xpkNUKE_1.8(000).library` (2,584 bytes, single 3E9
  code hunk of 2,464 bytes = 0x9a0)
- Identity: `$VER: xpkNUKE V1.8 (1 Oct 2013) by Christian von Roques`;
  short name `NUKE`, long `Nuke V1.8`, "A relatively efficient packer
  that unpacks very quickly" (flags 9)
- Kind: XPK sublibrary — packer + unpacker, pack-mode "normal"
  (XpkMode at code+0x910: PackSpeed 0x1d, UnpackSpeed 0x1bf, Ratio
  0x1c6).  Ten vectors, standard xpk sublib shape; relative-offset
  functab whose three null vectors point at the code+0 entry stub.
- CPU: plain 68000; no AttnFlags gate in LibInit.
- Generation note: this is an earlier codebase than 1.9 — same codec
  format, but a different init/alloc/lifecycle arrangement (see
  `findings/quirks.md` for the deltas).
- Reconstruction: `source/xpkNUKE.c` (all four real functions),
  `source/xpkNUKE_lib.s` (RomTag, datatab, lifecycle asm — lib base
  arrives in a6), `source/genfunctab.py` + `functab_stub.s` +
  `tail.s` (two-pass word-offset functab); built `-m68000`.
- Oracle: `work/oracle.py` (machine68k) — lifecycle, PackerInfo
  descriptor, 20-corpus pack streams byte-identical to the original,
  unpack round-trips, PackFree stale-pointer reuse, tiny-outbuf error.

## Layout of this bundle

- `structures/layout.md` — lib base + workspace map + XpkSubParams use
- `functions/vectors.md` — vector map, entry/exit behaviour per LVO
- `algorithms/codec.md` — NUKE stream format, hash chains, emit order
- `findings/quirks.md` — 1.8-vs-1.9 deltas + original defects reproduced
- `log.md` — chronological work log
