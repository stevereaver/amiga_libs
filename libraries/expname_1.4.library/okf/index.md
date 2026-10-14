# expname.library 1.4 (20.7.95)

`binary/expname_1.4.library` — 2500 bytes, single CODE hunk (0x8bc),
DREL16 relocations (108 word offsets, target hunk 0).  Richard Koerber's
expansion-board name database library (Aminet `util/libs/expname*`).

Reconstruction: `source/expname_lib.s` — pure 68000 assembly, byte-
identical output (md5 `5e1d4ddd4bb15aa4f6c8fe7f9c398f9a`).  `make` in
`source/` assembles with m68k-amigaos-gcc and post-processes the link
with `drel16.py` (GNU ld emits RELOC32; the original used DREL16).

The single public entry point is `ExName()` at LVO -30: it maps an
expansion board pointer — or a raw manufacturer/product id pair — to
human-readable name strings via sorted lookup tables embedded in the
code hunk (see `structures/tables.md`).

Verified: file byte-identical; `work/oracle.py` drives init, all
vectors, ExName hit/miss/board-pointer paths, deferred expunge —
identical output on original and rebuild.

- [functions/vectors.md](functions/vectors.md) — LVO map and calling convention
- [structures/layout.md](structures/layout.md) — library data + RomTag/InitTable layout
- [structures/tables.md](structures/tables.md) — manufacturer/product database format
- [findings/quirks.md](findings/quirks.md) — quirks and oddities
- [log.md](log.md) — work log
