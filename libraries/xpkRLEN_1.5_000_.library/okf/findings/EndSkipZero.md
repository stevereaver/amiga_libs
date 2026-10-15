# rt_EndSkip is literal 0

The RomTag at hunk+0x04 stores `rt_EndSkip = 0x00000000` — a
literal zero longword, not a relocated pointer (there is no RELOC32
entry for hunk+0x0a, unlike every other pointer field).

A zero EndSkip points at the hunk start, i.e. InitResident/FindResident
will scan the resident to the end of memory rather than stopping at
the structure.  Harmless in practice (the match word + tag are still
found and 0 is used only as the scan bound), but sloppy: 1.4 pointed
rt_EndSkip one past the hunk end (0x278).  Probably a
`DC.L end- resident` expression that evaluated wrong in the 2013
build.
