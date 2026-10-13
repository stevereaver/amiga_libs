# support.library 1.2 — RE log

- Picked as next-smallest pending library (2200 bytes) after
  mhimpegit_1.2 (AMIGALIBS-108).  Single CODE hunk, packed AUTOINIT
  RomTag — initially misread the hunk body by 4 bytes which put the
  RomTag at +0x62 with nonsense pointers; corrected to +0x66 and the
  layout resolved cleanly.
- Decoded by hand + IRA: InitTable {42, functab→+0xc4, datatab→+0x110,
  initfn→+0x13c}, 18 vectors -6..-108, datatab quirk (ver/rev 3.4 vs
  idstr 1.2), shared scratch at code+0x700, dead banner routine at
  code+0 calling dos Output/Write.
- Resolved external calls: exec OpenLibrary/CloseLibrary/Remove/
  FreeMem; dos Output(-60)/Write(-48) for the dead banner; the
  a6@(-36)/a6@(-84)/a6@(-30) calls inside -102 are mathffp.library
  SPFlt/SPDiv/SPFix through a caller-supplied a4 — identified via NDK
  LVO tables (not exec).
- First C/ASM build: assembler relaxation shortened the prologue by 6
  bytes (lea abs→PC-rel, movel #46→moveq) moving the RomTag to +0x60;
  fixed by emitting the two instructions as raw words — header region
  now byte-identical modulo reloc pointers, RomTag back at +0x66.
- Split the scratch+endskip into a tail object (support_end.s) so
  rt_EndSkip points at the hunk end as shipped.
- Oracle (`work/oracle.py`) emulates exec AUTOINIT (MakeLibrary +
  InitStruct + initfn) plus dos Output/Write and a mathffp integer
  model.  `work/exercise.py` drives 66 scripted cases on original and
  rebuild.
- First run exposed two real bugs in my -30 port (counter base
  inverted: mode3 keeps 0x40020050; counter re-based per pass, not
  once) — corrected after re-disassembling the 0x1ce-0x350 region
  where the first pass had been decoded desynced.  Also pinned the
  deterministic d0 residues (rowlen/0/final-c/half-1/w*30/h) as
  return values.
- Result: 66/66 cases identical — init + header bytes, open/close/
  expunge lifecycle incl. deferred and post-mortem double-expunge,
  all 10 snap scenarios incl. repick/scratch-pass paths, every buffer
  transform byte-for-byte, the full SPFlt/SPDiv/SPFix call sequence,
  scratch writes (0xf0 on the fit path), and the dead banner.
- Data/code region +0x00..+0x13c byte-identical to original modulo
  relocatable pointers; reloc offset set identical.
