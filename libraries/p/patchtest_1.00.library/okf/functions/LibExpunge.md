# LibExpunge (LVO -18)

Standard: if lib_OpenCnt != 0 set LIBF_DELEXP, return 0.
Otherwise frees the fixup buffer (base+0x2e, size = *p*4+4),
Remove()s the node, FreeMem()s the base, returns the seglist.
Reconstruction keeps Remove + FreeMem + seglist.
