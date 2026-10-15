# freeanim.library 40.9 (11.8.95) — OKF index

Working (non-stub) AUTOINIT library. Single CODE hunk (76 longs,
304 B); file 396 B, MD5 `03cd7bf7fd38450a49c3bc53d25f7dcf`.

Reconstruction: `source/freeanim.s` + `Makefile` + `fixup.py`
(reloc-group order only). Byte-identical to the original;
runtime-oracle identical (`work/oracle.py`).

RomTag @ h0+4: AUTOINIT|0x01 (0x81), v40 r9, NT_LIBRARY pri 0,
name/idstr at h0+0x1e/0x2f, InitTable at h0+0x54
(dsize 0x26, functab->0x64, datatab->0x70, initfn->0x120).
Functab is word-offset mode (0xffff markers): 4 vectors,
entries relative to the functab address.

Vectors: Open (+opencnt), Close (-opencnt, deferred expunge on
LIBF_DELEXP), Expunge (exec.Remove + FreeMem of lib), reserved
-24 -> `moveq #0; rts`. No public API beyond the standard four —
the library is an empty skeleton, like the 40.29 sibling but with
a real open/close/expunge lifecycle.

initfn @0x120 stores the seglist at lib+0x22 for expunge.
Dead `moveq #-1,d0; rts` stub sits at h0+0 before the RomTag.

See `functions/vectors.md`, `structures/layout.md`,
`findings/quirks.md`, `log.md`.
