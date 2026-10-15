# Structures

- XpkInfo / XpkMode / XpkSubParams: public XPK sublibrary ABI, from
  xpk_Develop `xpk/xpksub.h`.  Both descriptors are a STATIC data
  island inside the CODE hunk (XpkInfo at hunk+0x1f6, XpkMode at
  hunk+0x24e with mode string "normal").
- XpkSubBase: private library base, dataSize 0x26 (Library node +
  xsb_SegList@+0x22 only; SysBase is NOT saved — expunge reads abs 4).
- InitTable / function-table layout: AUTOINIT RomTag (flags 0x80);
  word-offset functab bracketed by 0xffff, signed offsets from the
  table start; null slots point at hunk+0 (the entry stub).
