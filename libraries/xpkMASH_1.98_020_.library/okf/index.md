# xpkMASH_1.98_020_.library — OKF index

- Binary: `binary/xpkMASH_1.98(020).library` (2,796 bytes, single
  3E9 code hunk of 2,632 bytes (0x292 longs) + 28 RELOC32 relocs;
  md5 `b92fd3db12b87e806f85949130439ef0`)
- Identity: `$VER: xpkMASH.library_020 V1.98`; short name `Mashiner`,
  "MASH.020 V1.98, good packer",
  "WindowSize: 32KB, 2 mixed streams  Dynamic Buffer Allocation"
  (flags 0x8009)
- Kind: XPK sublibrary — packer + unpacker, one mode record
  (upto=100, packmem 0x11000, packspeed 17, unpackspeed 400,
  ratio 0x1d8).  Ten vectors, absolute-long functab.
- CPU: 68020 build (68020 code forms; separate CPU-type variant of the same packer).
- Reconstruction: `source/xpkMASH.s` — full assembly transcription
  (resident module, RomTag, InitTable, InitStruct data, XPK info +
  mode records, compressor, decompressor, emit/decode tables).
  Built `-m68020`; `make verify` compares against the original:
  **BYTE-IDENTICAL** (whole file, header+reloc included).
- Oracle: `work/run_oracle.py` + `work/oracle.py` (machine68k) —
  lifecycle, PackerInfo descriptor, corpus pack/unpack streams,
  allocator traces, failure paths.  `work/difftest.py` runs
  original and rebuild in separate processes (machine68k trap
  dispatch is global; two Libs in one process corrupt each other)
  and diffs reports + streams.

## Result

- Rebuilt library is **byte-identical** to the original
  (`cmp` clean; 2,796 bytes).
- `difftest.py`: reports identical, 40 packed streams identical,
  40/40 unpack round-trips OK on both sides.
- Cross-check: packed streams byte-identical to the 000 build's
  across the whole corpus; the only differences are the `_020`
  id/long-name strings.

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
- `dis020.txt`, `code020.bin` — earlier disasm dumps
- `streams_orig020/` — earlier single-mode stream captures
- `streamsO2/`, `streamsO3/`, `streamsR2/`, `streamsR3/` — repeat-run
  stream captures (stability check)
