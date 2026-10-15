# 68020.library 46.4 (MMU) — RE Log

- 2,424 bytes, two hunks (CODE 1,524 / DATA 536).  md5-verified
  byte-identical to the already-reconstructed
  `68020_46.4.library/binary/68020_46.4.library` — the (MMU) name is a
  second shipment of the same driver.
- Raw diff vs 46.3 (`68020_46.3_MMU_.library`): code hunk grew by
  exactly 12 bytes, data hunk same size.  Everything downstream of the
  insertion is identical modulo +0x0c branch/reloc shifts.
- The single functional delta vs 46.3: a `CacheControl(d0=1, d1=1)`
  call (jsr ExecBase@-648, bit 0 = CACRB_EnableI) inserted in LibInit
  between the second PatchTable batch and the NOMMU/FPU-tail block.
  The instruction cache is re-enabled once the vectors are patched.
- Datatab/code diffs at 0x63-0x6b are bnw/beqw displacement words for
  the fail path; the `movel #0x2e0004,a4@(20)` long bumps lib_Revision
  3->4.  Data-hunk diffs are the idstring ("46.4 (23.07.2017)"),
  the functab/patch-base/excvec code pointers (all +0x0c) — all
  relocation-driven, no table-content changes.
- Patch region byte-identical (one relocated absolute pointer inside
  the p5emu helper moved +0x0c).  Same 10 exec/input patch records,
  same exception table, same 0x74 private base.
- Reconstruction = 46.4 sibling sources (themselves 46.3 + the
  CacheControl call + rev/date bump), copied verbatim since the target
  binary is the same file.  Built with m68k-amigaos-gcc -m6802; the
  rebuild is byte-identical to the sibling's build (4,292 bytes,
  md5-equal), CODE hunk 1,616 vs 1,524 — not file-identical to the
  original, matching the sibling standard.
- DATA hunk verified: all 48 relocation sites identical, every
  non-relocated word byte-equal — InitTable, function table, strings
  (incl. "p5emu.library"), both patch tables and the 7-entry exception
  table are exact.
- machine68k oracle: `work/oracle.py` (unchanged, takes the binary path
  as argv[1]) plus `work/matrix.py`, an 11-case differential matrix
  with code-address normalization.  Happy path (MMU/no-MMU, FPU/no-FPU),
  CPU rejects (030+, 68000), all OpenLibrary/FindName failure paths,
  p5emu absent, mmu -150 NULL — including the `cachecontrol` log entry
  landing between the second setfunc batch and the supervisor/mmu-copy
  tail.  Result: MATRIX DIFF: CLEAN.
