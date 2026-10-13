# iff.library 16.4 — work log

- Parsed hunk: single CODE hunk, RomTag AUTOINIT v16 pri 1,
  InitTable dataSize=58 / functab@+0xa4 / datatab@+0xe4 /
  initfn@+0x110.  15 vectors, 25 self-relocations.
- Bootstrap at +0x00 is a working CLI command (opens
  dos.library, `Write(Output(), id, 45)`, returns 5); the
  `'CHW!'` longword + `bra` shields it from resident scan.
- datatab decodes with extended InitStruct opcodes
  (`e0`/`d0`/`c0` = 24-bit-offset byte/word/long forms).
- LibOpen/Close maintain a per-task 22-byte node list at
  lib+44 via findnode helper +0x7dc (FindTask match at node
  +14, error longword at +18); second open by the same task
  fails.  Private delayed-expunge flag is bit 3 of lib+38
  (private word, NOT lib_Flags).
- LibExpunge is correct: Remove, CloseLibrary(DOSBase),
  seglist return, FreeMem positive area.
- Mapped API: OpenIFF/NewOpenIFF (whole-FORM load, 8SVX→CHIP
  autodetect), CloseIFF, FindChunk (word-rounded walk through
  `chunkstart+formsize`, i.e. 4 bytes past real chunk end),
  GetBMHD, GetColorTab (CMAP triples → 0x0RGB, nibble shift),
  DecodePic (ILBM-only, raw + ByteRun1, mask rows to scratch),
  SaveBitMap/SaveClip (streamed FORM, seek-back size patch,
  BODY header written last), IFFError (per-task, read+clear),
  GetViewModes (CAMG chunk or derived: width>400&&depth<=4 →
  HIRES, height>=320 → LACE, depth>=6 → HAM).
- ByteRun1 decoder quirks confirmed by disassembly: `0x80`
  treated as 129× replicate (not NOP); runs not clipped at
  rowbytes (overrun into following bytes); decoder entry for
  raw path lands mid-loop on the `dbf` → exactly rowbytes
  copied (NOT rowbytes+1 — corrected after first oracle diff).
- Depth check `cmpb bm_Depth,nPlanes; blss` is BLS (≤):
  DecodePic accepts nPlanes == bm_Depth (corrected after
  edge-case diff).
- Save worker: builds 268B stack header (FORM/ILBM/BMHD/CAMG/
  CMAP), flag bit7 → CAMG.HAM + comp&0x7f, streams rows via
  save_raw/save_crunch (+0x654/+0x672), literal cap 127,
  run cap 128, then Seek(0) + rewrite header + BODY header
  written after the body data.
- Reconstruction: `source/iff.c` (API + DOS/Exec inline
  wrappers + local `__mulsi3`; CMAP uses 16-bit div to avoid
  `__udivsi3`) + `source/iff_lib.s` (bootstrap, RomTag,
  functab, datatab, init, lifecycle, vector glue).
- Built 4956-byte single-CODE-hunk library with
  m68k-amigaos-gcc -m68000 -O2 -nostdlib.
- machine68k oracle: full-battery + edge battery **byte-
  identical** vs original (incl. 0x80 replicate, row overrun,
  short-read acceptance, id-0 end marker, deferred expunge).
