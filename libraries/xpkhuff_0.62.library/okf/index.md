# xpkHUFF.library 0.62 — OKF index

XPK compression sublibrary: **static-order Huffman** — builds a
fresh Huffman tree per chunk (sorted-list pairwise merge,
tie-broken toward the last equal-count leaf), serialises the
code table as `len-1` + MSB-first code bytes, then emits an
MSB-first bit stream.  Optional password layer scrambles every
byte after the 6-byte header.

**1992 ancestor of xpkHUFF 0.64 (1997).**  The codec proper is
algorithmically IDENTICAL to 0.64 — same workmem maps, same
node records, same word-bound `dbf` loops, same wire format,
same error codes — but the skeleton is the earlier generation:

- `dataSize 0xa8`: LibInit builds the XpkInfo (+0x26) and
  XpkMode (+0x7e) descriptors into the library private data at
  run time; seglist lives at lib+34 (same convention as
  xpkSQSH_1.10).  0.64 shrank to `dataSize 0x22` with a
  code-resident descriptor and a code-cell seglist.
- Executable entry point is a dos.library "You can't execute"
  Write stub (0.64: `moveq #0,d0; rts`).
- `rt_IdString` points *past* the `$VER: ` prefix (+6).
- LibExpunge writes DELEXP on the **library** flags correctly —
  deferred expunge WORKS here (0.64 has the ExecBase+14 bug).
- LibExpunge's vestigial dead call is a register-neutral
  moveml/nop/moveml sub (`_subnoop`), not a bare null stub.
- -42/-48/-60 are bare `rts` stubs (d0 passthrough); 0.64
  returns 0 explicitly.
- 10 bytes of dead data after the last stub: `{0, 8, 0x32e}`.

- Binary: `binary/xpkhuff_0.62.library` — 2696 bytes, single
  0xa00-byte CODE hunk, m68000, id string
  `xpkHUFF.library\xa0V\xa00.62 ($DATE:\xa0Mon Aug 10 10:31:44
  1992 by M.Zimmermann (zimerma@helios.ibr.cs.tu-bs.de))`.
- Reconstruction: `source/` — C core (`xpkhuff.c`, with a
  `HOST_TEST` path) + AutoInit glue (`xpkhuff_lib.s`).
- Library name `xpkHUFF.library`, XPK id `'HUFF'`,
  flags `0x2009`, single mode record (upto 100, DefMode 50,
  chunk 0x3f, PackMem 0x7324 / UnpackMem 0x1141a).

## Verification status

Byte-identical pack streams vs the original on the full corpus
(16 standard tests + 5 skewed 4-16k inputs + >64k boundary
inputs), identical unpack output (including wild-read U.B.
corners), identical return codes on every error path, identical
lifecycle behaviour (deferred expunge fires correctly),
identical dos-entry-stub message Write, identical descriptor.
Oracle: `work/oracle.py` (machine68k), `work/verify.py`,
`work/lifecycle.py`.

## Contents

- `functions/vectors.md` — LVO table + entry points
- `functions/packer.md` — pack algorithm
- `functions/unpacker.md` — unpack algorithm
- `structures/layout.md` — lib base/code layout, workmem,
  descriptor, stream format, password hash
- `findings/defects.md` — shipped quirks and bugs
- `log.md` — RE session log
