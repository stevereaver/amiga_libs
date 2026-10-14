# version40.42WB3.1 — OKF index

Workbench-version placeholder library — `version 40.42 (18.2.94)` (WB3.1).
Single CODE hunk (48 longs, 192 B); file 272 B, MD5 `1d6d42752095043c698f8d3d64864a60`.

Reconstruction: `source/version.s` + `Makefile`, byte-identical.
Minimal oracle value: only exec FreeMem (-210) inside the
unconditional expunge-on-last-close path.

RomTag @ h0+4: AUTOINIT, NT_LIBRARY pri 0, name/idstr at
h0+0x1e/0x2e, InitTable @ h0+0x48 (dsize 0x2a, functab->0x58
word-mode, datatab 0, initfn->0x64). Four vectors: Open 0x78,
Close 0x80 (expunges inline when opencnt hits 0 — no DELEXP
check), -18/-24 -> shared `moveq #0,d0;rts` @0xba.

See `functions/vectors.md`, `structures/layout.md`,
`findings/quirks.md`, `log.md`.
