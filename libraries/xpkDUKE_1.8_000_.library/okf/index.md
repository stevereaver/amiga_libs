# xpkDUKE.library V1.8(000) — reverse engineering index

XPK compression sublibrary, "Duke V1.8" by Christian von Roques
(1 Oct 2013). Per its own descriptor: **"NUKE with a delta
preprocessor"** — the codec is byte-identical to xpkNUKE 1.8(000)'s
LZ cruncher; DUKE only wraps it in a byte-delta transform.

## Files

- `binary/xpkDUKE_1.8(000).library` — original, 2548-byte file,
  single CODE hunk (0x277 longwords = 2524 bytes at file offset 0x20).
- `source/` — byte-compatible reconstruction:
  - `xpkDUKE.c` — codec (delta pre/post + verbatim NUKE core)
  - `xpkDUKE_lib.s` — RomTag/InitTable/datatab/lifecycle/XpkInfo
  - `genfunctab.py`, `functab_stub.s`, `tail.s`, `Makefile`
  - built artifact: `source/xpkDUKE.library`
- `work/oracle.py` — machine68k oracle; `work/duke_dis.txt`,
  `work/duke_code.bin` (extracted hunk + disassembly; `code.bin`/
  `code.dis` are the same from an earlier pass);
  `work/streamsO/` original streams, `work/streamsR2/` rebuild
  streams (all 20 byte-identical); `work/orc_new.log`.

## Result

301 randomized + 20 corpus inputs: pack output byte-identical,
return codes identical, unpack round-trips identical, lifecycle
traces identical. See `log.md` for the run log and `findings/quirks.md`
for defects reproduced.

## Contents

- `functions/vectors.md` — vector/LVO map and lifecycle behavior
- `structures/layout.md` — hunk, RomTag, XpkSubParams, workspace
- `algorithms/codec.md` — delta layer + NUKE stream format
- `findings/quirks.md` — bugs and quirks (all preserved)
- `log.md` — verification log
