# LibExpunge (LVO -18)

Standard expunge: if `lib_OpenCnt != 0`, sets LIBF_DELEXP and
returns 0.  Otherwise restores SysBase from base+0x26, saves the
seglist (base+0x22) in d2, `Remove()`s the node, `FreeMem()`s
`base-NegSize` for `NegSize+PosSize`, returns the seglist.
