# Work log — explode_7.0(040-060).library

## Reverse engineering

- Hunk parse: single `HUNK_CODE` (0x3e9) hunk, 0x1a1 longs =
  1668 bytes, one `HUNK_RELOC32` (16 offsets, all self-hunk:
  0x6/0xa/0x12/0x16/0x1a romtag+inittable pointers, 0xaa-0xca
  functab, 0xdc/0xf6 datatab name/idstr), `HUNK_END`.  Extracted to
  `work/code.bin`; disassembled with m68k-amigaos-objdump
  (`work/full.s`).
- RomTag @4: RTF_AUTOINIT, rt_Version 7, NT_LIBRARY pri 0;
  endskip 0x682.  InitTable @0xa6: datasize 0x36, LONG functab @0xb6
  (6 vectors + -1), datatab @0xd2, initfunc @0xfe.
- **Byte-identity**: `cmp` + md5 (`a3a6c7fa59ef63b0b432d32f98efa09e`)
  prove this file identical to `explode_7.0.library` — the "(040-060)"
  suffix names the build that already contains the 68040/60 CacheClearU
  bugfix; no CPU check, no 020+ instructions anywhere.

## Reconstruction

- `source/` = the verified sibling sources (explode_lib.s verbatim
  asm + explode.c lifecycle + Makefile, `-m68000 -O2 -ffixed-a5`).
  Rebuild via `make` produces a 2960-byte single-hunk library (larger
  than the 1784-byte original: gas/vlink-style layout with C code
  appended after the asm block and a SYMBOL hunk).
- Removed stale `source/README.txt` (predated the local sources).

## Oracle fixes (work/oracle.py, inherited from previous pass)

The harness had two AUTOINIT-emulation bugs that made every test fail:

- **InitStruct decode**: commands are word-aligned per
  `exec/initializers.h` (INITBYTE = `e000|offhi, off, value<<8`).
  The old parser consumed only the value byte, so the pad word of the
  first `e0` command read as a 0 terminator — only ln_Type was ever
  written and ln_Name/flags/version/idstr stayed garbage.
- **Base vs allocation**: the old code ran InitStruct and the initfn
  against `LIB - negsize` (the allocation start) instead of `LIB`
  (the node).  Fixed: vectors at `LIB-6-6i`, InitStruct + initfn
  d0 = `LIB`, `FreeMem` expectation remains `LIB-neg, neg+pos`.
- `--diff` now reports a matching-prefix length from the NL stub
  instead of comparing misaligned tails.

## Verification

- `oracle.py --diff` original vs sibling original: **0 byte diffs**
  (1784/1784, code hunks identical, verbatim prefix 1170 B).
- `oracle.py --diff` original vs rebuild: header+tables 0x00-0xfd
  identical modulo relocated pointers; verbatim asm block (NL stub ->
  endskip, **1168 bytes, 0 diffs**); C lifecycle code relocated to the
  hunk tail (expected codegen differences).
- `oracle.py original`: **33/33 PASS** — init wedge install order
  (openlib, forbid, setfunc x2, cacheclearu, permit), saved-vector
  stores, Open/Close/-36 flag arithmetic, dead -18/-24 vectors,
  expunge-via-last-close (restore order, Remove, CloseLibrary,
  FreeMem geometry, seglist return), wedge pass-through on NULL /
  unsigned / bad-marker segments on both stubs, init-failure defect.
- `oracle.py rebuild`: **33/33 PASS** — identical behaviour.
- Not covered (as in sibling): signature-match inflate and the -30
  Explode decoder entry — no packed sample exists; the decoder is
  verbatim-transcribed asm proven by the 0-diff region compare.

## Inconsistencies recorded (reproduced, not fixed)

- lib_Version 6 / rev 0 vs "7.0" idstring and rt_Version 7.
- init returns success on OpenLibrary failure (no wedge installed).
- unconditional vector restore on expunge (no slot check).
- incomplete second signature ("ed explode.libra" — tail unchecked).
- See `findings/defects.md` for the full list (9 items).
