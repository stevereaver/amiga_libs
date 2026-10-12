# bfbplayWHIT.library -- work log

- HUNK parse: single CODE hunk 1948B + 32 relocs; standard packed
  RomTag, AUTOINIT InitTable {dsize 0xb2, functab 0x10a,
  datatab 0x146, init 0x166}.
- Family match vs bfbplayGMOD (already reconstructed): same
  lifecycle, tag-driven InitModule, CIA ICR -> Cause -> softint
  interrupt chain; WHIT calls modbuf+0/+14/+28/+42 (GMOD: +20/
  +40/+24) and uses a signature-scanning subsong detector instead
  of modbuf+64.
- Functab = 14 entries; -48 = StopModule (internal helper too),
  -54 = ContModule resume (running==0 && stopped==1 -> modbuf+42).
- whit_detect (0x5b0): two signature scans (43fa/4880c0fc/41fa,
  then 47fa+51eb/33fc/426b), resolve lea, sweep offset table at
  a0+12+d2; result in d5 -> sess+20.  First-scan counter is the
  module pointer minus 28 (unbounded defect).
- CIA: ensure_resources lazily opens ciaa then patches the name
  string a->b for ciab; cia_start tries AddICRVector bit0/bit1 on
  ciaa then ciab; period 0x3781; CRA/CRB=0x11.
- Reconstruction: C + asm skeleton (AUTOINIT, identical datatab
  bytes, 14-vector functab, same interrupt-chain tail with
  modbuf+14 dispatch).
- Build fix vs the GMOD template: `(struct ExecBase *)4` emits
  `moveaw #4,a6` (a6 = address 4); must be `*(ExecBase**)4` to
  match the original `moveal 4:w` SysBase indirection.
- Musashi oracle (work/whit_test.py): crafted fake module with
  the detector signatures; ORIG vs REBUILT identical on
  InitModule file/mem paths (session alloc 80B, dos
  open/seek/read/close sequence, modbuf alloc 130 for len 128),
  +20=1, PlayModule (openres ciaa+ciab, addicr, mod+0, flags
  1/0/1), Cont no-op, SetSubsong restart (mod+28 + mod+0, +24=1)
  and clamp, GetDesc string, EndModule frees, and the full
  CIA->Cause->softint->mod+14 tick chain.
- Plane: AMIGALIBS-100.
