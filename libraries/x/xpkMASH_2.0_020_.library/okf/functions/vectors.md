# Vectors — xpkMASH 2.0(020)

Word-offset functab at code+0x92: `ffff` marker word then
ten offsets relative to the marker.  LibInit runs through
exec InitResident (RTF_AUTOINIT).

## Lifecycle

- **LibInit** (code+0xaa, via InitTable): stores the seglist
  at base+34, reads SysBase at abs 4, `btst #1,AttnFlags(297)`
  — returns the lib base on 68020+, `moveq#0;d0 rts`
  (refuse) below.  InitStruct datatab at code+0x72 fills
  ln_Type=9, ln_Name, lib_Flags=6, lib_Version=2,
  lib_Revision=0, lib_IdString (the two longs are patched
  by hunk relocations at load).
- **LibOpen** (0x0c0): `addq #1,32(a6)`;
  `bclr #3,14(a6)` (LIBF_DELEXP); returns a6.
- **LibClose** (0x0ce): `subq #1,32(a6)`; if nonzero or
  LIBF_DELEXP clear → `rts` (branch past Expunge); else
  falls into Expunge.
- **LibExpunge** (0x0e0): if open count nonzero →
  `bset #3,14(a6)`, return 0.  Else Remove(a6) via
  SysBase@-252, FreeMem(base-NegSize, NegSize+PosSize)
  via -210, returns the seglist in d0.

## XPK entries (xsp in a0; vector stubs push a0 and call C)

- **-30 XpksPackerInfo** (0x11e): `lea` + `move.l` —
  returns the XpkInfo descriptor at code+0x6d4.
- **-36 XpksPackChunk** (0x140): the whole packer.  If
  `xsp_Work` (params+0x34) is NULL, `AllocMem(0x20000 +
  2*inlen, 0)` (head table + gap array); the size is saved
  at params+0x38, `xsp_Bound` (params+0x3c) is set to
  `OutBuf + InLen - 10`, `xsp_Tries` (params+0x40) to 1024.
  Then: clear [wk, wk+0x20000), pass1 (gap array), pass2
  (lazy matcher -> records over the head table), emit_all
  -> packed length in params+0x10.  Returns 0 or -17.
- **-42 XpksPackFree** (0x126): `FreeMem(xsp_Work,
  xsp_WorkSize)` — does NOT clear `xsp_Work` (use-after-free
  defect; see findings).
- **-48 / -60**: the entry stub (`moveq #0,d0; rts`) —
  MASH 2.0 has no PackReset and no UnpackFree; the xpk
  dispatcher gets a harmless ret0.  Note the original's
  reloc[0] on code+0 corrupts this stub at load (see
  findings).
- **-54 XpksUnpackChunk** (0x518): the decoder.  Reads
  params+0 (in), +4 (inlen), +8 (out), +0x10 (expected
  outlen).  Returns 0; malformed streams can run wild
  (see findings).
