# xpkDMCU 41.0 — quirks & reconstruction notes

## Defects / latent issues in the shipped binary

- **Null-A6 ppc calls.** `_v54` (and mirror `_v36`) attempt to create
  the ppc job objects (`jsr -0x3c(a6)` with `a6 = _gd+0x7c`) whenever
  `a5+0x34/0x38` are both zero — without checking that
  `ppc.library` actually opened. On a system with no ppc.library
  (`_gd+0x7c == 0`) this is a wild `jsr 0xfffffc4` instead of a clean
  native fallback.
- **Dead entry stub at h0+0**: `moveq #-1,d0; rts` before the real
  initfn (same vestigial entry seen in other SAS/C libs).
- **RomTag lives in the DATA hunk**, packed at h1+0xe4 — unusual but
  self-consistent (`rt_Init -> h1+0` InitTable).

## Reconstruction notes

- Two-hunk AUTOINIT: InitTable + functab + datatab + RomTag all in h1;
  `a4`/`_gd` = h1 base (SAS/C near-data). Code hunk references _gd
  fields via `lea _gd+N(pc,a4)` long-form relocations.
- GNU `as` canonicalized several encodings; raw `.short` emits used
  for: `moveq #-1/#-17/#-4` (out of signed-syntax range vs original
  bytes), two 68020 scaled-index `lea` (`43f0 7c00`, `43f0 6c00`)
  rejected under `-m68000`, and capstone-skipped data islands.
- `fixup.py` rewrites each hunk's RELOC32 groups into the original
  unsorted offset order — body bytes were identical before fixup;
  only relocation-record ordering differed.

## Oracle coverage

`work/oracle.py` exercises: AUTOINIT init incl. the full ppc.library
v45 open + `xpkDMCU.elf` load + object-pool iteration protocol,
Open x2, ExtFunc, info table, -42 free, -36/-54/-60 dispatch entry,
deferred expunge + real expunge teardown (ppc object release +
CloseLibrary + Remove + FreeMem). Original and rebuild traces are
identical (RUNTIME-IDENTICAL). The native coder paths and the
ppc-job submission bodies return early on the null fixture; deep
coder equivalence is covered by byte-identity.
