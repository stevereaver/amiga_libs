# freeanim.library 40.29 (1.4.94) — OKF index

Stub/placeholder library. Single CODE hunk (27 longs, 108 B);
file 188 B, MD5 `d55fa1c912ce38fd8d480cadbcc6ac72`.

Reconstruction: `source/freeanim.s` + `Makefile`, byte-identical.
Runtime-verified via machine68k oracle (`work/oracle.py`):
AUTOINIT construction + initfn -> 0 + all four vectors -> 0
identical between original and rebuild.

RomTag @ h0+4: AUTOINIT (0x80), v40, NT_LIBRARY pri 0,
name/idstr at h0+0x1e/0x2f, InitTable at h0+0x4a
(dsize 0x2a, functab->0x5a, datatab 0, initfn->0x66).
Functab is word-offset mode (0xffff marker): four entries 0x000c
-> functab+0xc = h0+0x66. EndSkip = 0x6a (points past the stub).

See `functions/vectors.md`, `structures/layout.md`,
`findings/quirks.md`, `log.md`.
