# Structures

- XpkInfo / XpkMode / XpkSubParams: public XPK sublibrary ABI, from
  xpk_Develop `xpk/xpksub.h`.  The library carries one XpkInfo block
  (hunk+0x1fe: flags, name, ID, description, mode strings) plus one
  XpkMode descriptor "normal" (hunk+0x256), both as static code-hunk
  islands — the InitStruct table only fills the Library node header.
- XpkSubBase: private library base, InitTable dataSize **0x26** =
  `struct Library` (0x22) + `xsb_SegList` (0x22).  1.4 reserved one
  extra unused long (0x2a); this build dropped it.
- InitTable / function-table layout: **AUTOINIT** (rt_Flags=0x80),
  InitTable at hunk+0x68, word-offset functab at hunk+0x98 (leading
  and trailing 0xffff markers, offsets relative to the table start,
  negative offsets allowed — the four dead slots hold -0x98 = hunk
  0).  An earlier note here describing a non-AUTOINIT
  absolute-longword table was wrong.
