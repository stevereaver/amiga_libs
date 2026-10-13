# 68020.library 46.4 — RE Log

- Started AMIGALIBS-125. 2,424 bytes, two hunks (CODE 1,524 / DATA 536).
  Successor of the reconstructed 46.3; `68020_46.4_MMU_.library` is a
  byte-identical copy (md5-verified).
- Raw diff vs 46.3: code hunk grew by exactly 12 bytes, data hunk same
  size.  Everything downstream of the insertion is identical modulo
  +0x0c branch/reloc shifts.
- The single functional delta: a `CacheControl(d0=1, d1=1)` call
  (jsr ExecBase@-648, bit 0 = CACRB_EnableI) inserted in LibInit
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
- Reconstruction = 46.3 sources + the CacheControl call + rev/date
  bump.  Built with m68k-amigaos-gcc -m68020.
- machine68k oracle: full 11-case init matrix identical — happy path
  (MMU/no-MMU, FPU/no-FPU), CPU rejects (030+, 68000), all
  OpenLibrary/FindName failure paths, p5emu absent, mmu -150 NULL —
  including the new `cachecontrol` log entry landing between the
  second setfunc batch and the supervisor/mmu-copy tail.
