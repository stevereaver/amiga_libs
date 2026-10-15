# xpkMASH_1.98_000_.library — OKF index

- Binary: `binary/xpkMASH_1.98(000).library` (2,816 bytes, single
  3E9 code hunk of 2,652 bytes + 28 RELOC32 relocs; md5
  `1527b4f331464f3013ba90ca44a91e54`)
- Identity: `$VER: xpkMASH.library_000 V1.98`; short name `Mashiner`,
  "MASH.000 V1.98, good packer",
  "WindowSize: 32KB, 2 mixed streams  Dynamic Buffer Allocation"
  (flags 0x8009)
- Kind: XPK sublibrary — packer + unpacker, one mode record
  (upto=100, packmem 0x11000, packspeed 17, unpackspeed 400,
  ratio 0x1d8).  Ten vectors, absolute-long functab.
- CPU: 68000 build (plain 68000 code; no CHKW/scaled-index forms).
- Reconstruction: `source/xpkMASH.s` — full assembly transcription
  (resident module, RomTag, InitTable, InitStruct data, XPK info +
  mode records, compressor, decompressor, emit/decode tables).
  Built `-m68000`; `make verify` compares against the original:
  **BYTE-IDENTICAL** (whole file, header+reloc included).
- Oracle: `work/run_oracle.py` + `work/oracle.py` (machine68k) —
  lifecycle, PackerInfo descriptor, corpus pack/unpack streams,
  allocator traces, failure paths.  `work/difftest.py` runs
  original and rebuild in separate processes (machine68k trap
  dispatch is global; two Libs in one process corrupt each other)
  and diffs reports + streams.

## Result

- Rebuilt library is **byte-identical** to the original
  (`cmp` clean; 2,816 bytes).
- `difftest.py`: reports identical, 40 packed streams identical,
  40/40 unpack round-trips OK on both sides.
- Cross-check: the 020 build produces identical streams modulo the
  `_020` id strings.

## Layout of this bundle

- `structures/layout.md` — hunk map, resident/init layout, lib base,
  XpkSubParams, workspace map, code region map
- `functions/vectors.md` — vector map, entry/exit behaviour per LVO
- `algorithms/codec.md` — MASH 1.98 stream format, two engines,
  emitter, decoder tables
- `findings/defects.md` — original defects/quirks reproduced
- `findings/v116_v20.md` — comparison vs MASH 1.16 and 2.0
- `log.md` — chronological work log

## work/ contents

- `oracle.py` — Lib class: hunk loader + exec emulation
  (AllocMem/FreeMem/Remove/CacheClearU stubs, InitStruct, LibInit)
- `run_oracle.py` — lifecycle + PackerInfo + corpus run for one
  binary, writes `streamsX/report.txt` + `*.pk`
- `difftest.py` — subprocess pair comparison driver
- `run_O.log` / `run_R.log` — captured original / rebuild reports
- `streamsO/` `streamsR/` — captured packed streams
- `xpkMASH_ref.c` — C reference transliteration of the codec
  (documentation value; the shipped reconstruction is the .s)
- `genasm.py`, `fixup.py`, `minimize.py` — transcription pipeline:
  capstone disasm -> devin assembly -> assemble/link -> byte-compare
  -> .short patch loop for encodings devin doesn't reproduce
- `patch000.txt`/`patch020.txt` — offsets emitted as .short
  (`movea.l $0(An),Am` zero-disp forms and `move.b (Ax)+,(Ay)+`)
- `dis000.txt`, `dis020.txt`, `code000.bin` — earlier disasm dumps
- `streams_orig000/` — earlier single-mode stream captures
- `randtest.py` — randomized differential driver (subprocess pair;
  N=150 -> 740 comparisons, 0 failures)
