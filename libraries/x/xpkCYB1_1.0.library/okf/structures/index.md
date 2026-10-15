# Structures

- XpkInfo / XpkMode / XpkSubParams: public XPK sublibrary ABI, from
  xpk_Develop `xpk/xpksub.h`.  Both descriptors are a STATIC data
  island inside the CODE hunk (XpkInfo at hunk+0x164, XpkMode at
  hunk+0x224) — they are not built in the library base.
- XpkSubBase: private library base, dataSize 0x4a (Library node +
  xsb_SysBase@+0x22 + xsb_SegList@+0x26, rest unused).
- InitTable / function-table layout: AUTOINIT RomTag (flags 0x80);
  functab is the absolute-longword variant (10 vectors + -1
  terminator), same as xpkNONE 1.2.
