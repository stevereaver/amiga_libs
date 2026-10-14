# easylife.library 1.02 — OKF index

Paul Hickman's "Easylife" dynamic multi-dimensional array library
(21.09.94). Compiled C (linkw frames, register args d0-d4/a0-a1),
AUTOINIT, single CODE hunk (2600 B, 0x28a longs). File 2764 B,
MD5 `5d44af290ba9299d96eeb83d53ac11cc`.

Reconstruction: pure 68k asm transcription (`source/easylife.s` +
`Makefile` + `fixup.py`), byte-identical to original. machine68k
oracle (`work/oracle.py`) shows identical traces for lifecycle,
pool init, table lookup, create/free, GET/SET dispatch, file I/O
and expunge paths.

See `functions/vectors.md`, `structures/layout.md`,
`findings/quirks.md`, `log.md`.
