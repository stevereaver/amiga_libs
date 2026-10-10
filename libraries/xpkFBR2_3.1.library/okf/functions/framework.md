---
type: Function
title: Framework functions
---
# Framework

Standard AUTOINIT library, dataSize 0x26.

- `LibInit` (init routine): stores the seglist BPTR at
  base+0x22, returns the base.
- `LibOpen` (-6): `lib_OpenCnt++`, clears LIBF_DELEXP,
  returns base.
- `LibClose` (-12): `--lib_OpenCnt`; expunges when the
  count hits 0 and DELEXP is set.  Returns 0.
- `LibExpunge` (-18): sets DELEXP + returns 0 when open;
  else exec Remove(node) + FreeMem(base-NegSize,
  NegSize+PosSize), returns seglist.
- `LibNull` (shared `moveq #0,d0; rts`): serves LVO -24
  (ExtFunc), -42 (PackFree), -48 (PackReset) and -60
  (UnpackFree).
- Entry stub (not vectored): `moveq #-1,d0; rts` —
  returns -1 where V4.x returns 0.
