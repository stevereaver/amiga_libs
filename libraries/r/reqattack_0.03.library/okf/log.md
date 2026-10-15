# Log

## 2026-10-11 -- reconstruction complete

- Parsed 5-hunk SAS/C-style binary: code hunk + four data
  hunks with cross-hunk RELOC32 groups.
- RomTag is decorative: RTF_AUTOINIT set, RT_INIT NULL,
  RT_ENDSKIP -> +0x1e (mid-init).  Real init path is the
  manual InitTable in hunk2 consumed by a private loader.
- LibInit writes every library field by hand (ln_Type 9,
  ln_Name, lib_Flags 6, ver 0, rev 3, idstr), runs the
  SAS/C far-data fixup over base+0x30 (empty table,
  count 0), then opens intuition.library into the hunk3
  stash.  Returns base / 0.
- Decoded the two public vectors: identical proxy
  skeletons -- Forbid / FindSemaphore / AttemptShared /
  Permit / FindPort / call port+46 base slot / Release /
  Permit / fallback to intuition -588/-594 on -3.
- Overlapping-instruction trick found in the init
  epilogue: `beq` lands mid-`cmpiw #0x200d` on `200d`
  = `movel a5,d0` (return base); the failure path runs
  the cmpiw as a dead instruction.
- Found: double Permit (Forbid once, Permit twice ->
  TDNestCnt underflows one per call); ENDSKIP -> mid-init;
  dead "li" tail bytes; empty fixup template.
- Reconstructed in C + minimal asm skeleton; all 6 vectors
  and the full exec/intuition LVO inventory verified
  against the shipped binary.
