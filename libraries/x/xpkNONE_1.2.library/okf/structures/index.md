# Structures

- XpkInfo / XpkMode / XpkSubParams: public XPK sublibrary ABI, from
  xpk_Develop `xpk/xpksub.h`.  The library embeds one XpkInfo block
  (flags, name, ID, description, mode strings) plus its XpkMode table.
- XpkSubBase: private library base (node + open count).
- InitTable / function-table layout: non-AUTOINIT, absolute-longword
  vectors placed before the RomTag in some versions.
