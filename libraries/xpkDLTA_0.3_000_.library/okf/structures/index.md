# Structures

- [XpkSubBase](XpkSubBase.md) — private library base (dataSize 0x26)
- [XpkInfo](XpkInfo.md) — packer descriptor island at code+0x15a
- [XpkMode](XpkMode.md) — mode descriptor island at code+0x1b2 ("bytemode")
- [InitTable](InitTable.md) — AUTOINIT table, InitStruct data,
  word-offset functab
- XpkSubParams: public XPK chunk I/O block (xpk_Develop `xpksub.h`);
  this version only touches `xsp_InBuf`, `xsp_InLen`, `xsp_OutBuf`
  and (pack only) `xsp_OutLen`.
