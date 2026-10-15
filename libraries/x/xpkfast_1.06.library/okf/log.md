# xpkFAST 1.06 — RE log

## Decode

- IRA/objdump disassembly of `binary/xpkfast_1.06.library`
  (2128B, single code hunk) -> `work/full.s` (gitignored).
- AUTOINIT resident, LONG-absolute functab, 10 vectors; `-24`,
  `-48`, `-60` are return-0 stubs (PackReset is a no-op, unlike
  1.2).
- Nonstandard datatab (`a0 0c` writes at +12, not +8);
  preserved verbatim.
- Codec: LZ77, 4095-byte window, len 3..18 tokens
  `(off<<4)|(18-len)`, literals forward + ctrl/token words
  backward, tail compaction — same wire format as 1.2.
- Speedy: stateful hash on d1 (bits 8..15 persist), single
  candidate, unsigned distance reject, 16384-entry table,
  in_end as empty marker, head/tail two-phase bound checks.
- Crawler: gram hash `(b0<<8)|((b1+b2)&0xff)`, 65536-entry hash
  via negative-biased long index (`0xfffc0000|g<<2` onto
  base+0x40000 — only the first 64 KB reachable), 4096-entry
  chain at +0x40000, `in-4096` init fill, stale-`d5` re-eval
  after matches (back-to-back match emission), `lf` counts the
  FAILED compare too (wire len = lf+1).
- Decoder: four ping-pong paths, sentinel-in-X flag register,
  asymmetric exhaustion checks, no output bound.

## Musashi oracle work

- `work/oracle.py` — hunk loader + reloc + exec stubs
  (AllocMem/FreeMem/Remove trap logging), functab walker.
- `work/probe*.py`, `work/fp*.py` — targeted traces: hash index
  math, drain X-bit, flag boundaries, stale-d5 re-eval.
- Early apparent divergences were all traced to **emulator
  state reuse** — the codec's OOB reads pick up stale heap.
  Fresh-machine runs are byte-identical.

## Reconstruction

- `source/xpkfast.c` — lifecycle, PackerInfo, PackFree,
  PackChunk (mode-select + realloc), speedy + crawling packers,
  shared pk_finish compactor, four-path unpacker.
- `source/xpkfast_lib.s` — EndSkip stub, RomTag, initstruct,
  byte-faithful nonstandard datatab, LONG functab (10 + -1),
  LibInit (execbase@34, seglist@38), XpkInfo descriptor +
  mode chain + strings.

## Bugs found & fixed during reconstruction

- Pad count: `(gap&3)+1` -> `gap&3` (DBF semantics; zero pad
  legal) — fixed a systematic 1-byte tail diff.
- Speedy ctop: `out+(inlen&~3)` -> `(out+inlen)&~3` (absolute
  alignment).
- Crawler `lf`: count the failed compare (equal+1), and
  re-evaluate stale `d5` after each match — fixed missed
  matches (e.g. trailing 'abc') and non-back-to-back emission.
- Functab entry count: 10 entries (not 9); both -48 and -60
  are stubs, -54 is the real UnpackChunk.

## Verification

- `work/regress2.py`: 86 cases x 2 modes, fresh machine per
  case, both binaries — **diffs: 0**; every stream byte-
  identical, every round-trip ok, every -17 agrees.
- Lifecycle + descriptor + stubs verified identical under the
  same oracle.
- Clean rebuild: `make` in `source/` -> xpkFAST.library (3776B;
  code hunk larger than the original 1960B — GCC codegen,
  expected; all vectors resolve via the LONG functab).
