# LibOpen (LVO -6)

Standard open: `addqw #1, lib_OpenCnt`, `bclr #3, lib_Flags`
(clears LIBF_DELEXP), returns the library base in d0.  Shipped
as a 7-instruction hand-coded routine at hunk+0x82.
